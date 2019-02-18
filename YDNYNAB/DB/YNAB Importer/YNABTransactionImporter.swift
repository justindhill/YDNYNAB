//
//  YNABTransactionImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB
import CSV

class YNABTransactionImporter {
    private enum Field: Int {
        case account
        case flag
        case checkNumber
        case date
        case payee
        case category
        case masterCategory
        case subCategory
        case memo
        case outflow
        case inflow
        case cleared
        case runningBalance
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter
    }()
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    init(csvFileUrl: URL, budgetContext: BudgetContext) {
        
        try! budgetContext.database.queue.write { db in

            var accounts: [String: Account] = [:]
            var payees: [String: Payee] = [:]
            
            guard let stream = InputStream(url: csvFileUrl) else {
                return
            }
            
            let csv = try CSVReader(stream: stream, hasHeaderRow: true, trimFields: true)
            
            var currentSplitParent: Transaction?
            
            while let row = csv.next() {
                let txn = Transaction()
                
                let rowSplitInfo = self.splitInfo(forRow: row)
                if rowSplitInfo?.index == 1 {
                    currentSplitParent = Transaction()
                    currentSplitParent?.masterCategory = YDNDatabase.SplitCategoryId
                    currentSplitParent?.subCategory = YDNDatabase.SplitCategoryId
                    try currentSplitParent?.insert(db)
                }
                
                if let currentSplitParent = currentSplitParent {
                    txn.splitParent = currentSplitParent.id
                }

                try! row.enumerated().forEach { index, value in
                    guard let field = Field(rawValue: index) else {
                        return
                    }
                    
                    let nilCheckedValue = value.count > 0 ? value : nil

                    switch field {
                    case .account:
                        let account: Account
                        if let existingAccount = accounts[value] {
                            account = existingAccount
                        } else {
                            account = Account()
                            account.name = value
                            try account.insert(db)
                            accounts[value] = account
                        }
                        if let currentSplitParent = currentSplitParent {
                            currentSplitParent.account = account.id
                        } else {
                            txn.account = account.id
                        }
                    case .flag:
                        txn.flag = Transaction.FlagColor(rawValue: value)
                    case .checkNumber:
                        if let currentSplitParent = currentSplitParent {
                            currentSplitParent.checkNumber = nilCheckedValue
                        } else {
                            txn.checkNumber = nilCheckedValue
                        }
                    case .date:
                        if let date = self.dateFormatter.date(from: value) {
                            if let currentSplitParent = currentSplitParent {
                                currentSplitParent.date = date
                                currentSplitParent.effectiveDate = date
                            }
                            
                            txn.date = date
                            txn.effectiveDate = date
                        }
                    case .payee:
                        let payee: Payee
                        if let existingPayee = payees[value] {
                            payee = existingPayee
                        } else {
                            payee = Payee()
                            payee.name = value
                            try payee.insert(db)
                            payees[value] = payee
                        }
                        if let currentSplitParent = currentSplitParent {
                            currentSplitParent.payee = payee.id
                        } else {
                            txn.payee = payee.id
                        }
                    case .masterCategory:
                        if value != "Hidden Categories" {
                            txn.masterCategory = BudgetMasterCategory.first(withName: value, inDb: db)?.id
                        }
                    case .subCategory:
                        if txn.masterCategory == nil {
                            // hidden category
                            let categoryInfo = value.split(separator: "`").map({$0.trimmingCharacters(in: CharacterSet([" "]))})
                            guard categoryInfo.count >= 2 else {
                                return
                            }
                            txn.masterCategory = BudgetMasterCategory.first(withName: categoryInfo[0], inDb: db)?.id
                            txn.subCategory = BudgetSubCategory.first(withName: categoryInfo[1], inDb: db)?.id
                        } else if txn.masterCategory == YDNDatabase.IncomeCategoryId {
                            if value == "Available next month" {
                                let actualMonthYear = MonthYear(date: txn.date)
                                txn.effectiveDate = actualMonthYear.incrementingMonth().date
                            }
                            txn.subCategory = YDNDatabase.IncomeCategoryId
                        } else {
                            txn.subCategory = BudgetSubCategory.first(withName: value, inDb: db)?.id
                        }
                    case .memo:
                        if let rowSplitInfo = rowSplitInfo, let currentSplitParent = currentSplitParent {
                            currentSplitParent.memo = rowSplitInfo.parentMemo
                            txn.memo = rowSplitInfo.childMemo
                        } else {
                            txn.memo = nilCheckedValue
                        }
                    case .outflow:
                        if let doubleValue = self.currencyFormatter.number(from: value)?.doubleValue {
                            txn.outflow = doubleValue
                            currentSplitParent?.outflow = (currentSplitParent?.outflow ?? 0) + doubleValue
                        }
                    case .inflow:
                        if let doubleValue = self.currencyFormatter.number(from: value)?.doubleValue {
                            txn.inflow = doubleValue
                            currentSplitParent?.inflow = (currentSplitParent?.inflow ?? 0) + doubleValue
                        }
                    case .cleared:
                        let cleared = (value != "U")
                        if let currentSplitParent = currentSplitParent {
                            currentSplitParent.cleared = cleared
                        } else {
                            txn.cleared = cleared
                        }

                    default:
                        break
                    }
                }
                
                if let rowSplitInfo = rowSplitInfo, rowSplitInfo.index == rowSplitInfo.count {
                    try currentSplitParent?.update(db)
                    currentSplitParent = nil
                }

                try txn.insert(db)
            }
        }
    }
    
    typealias SplitInfo = (index: Int, count: Int, parentMemo: String?, childMemo: String?)
    private func splitInfo(forRow row: [String]) -> SplitInfo? {
        guard let regex = try? NSRegularExpression(pattern: "\\(Split ([0-9]+)\\/([0-9]+)\\) (.*)") else {
            assertionFailure("Regex pattern didn't produce a valid regex!")
            return nil
        }
        
        if row.count < Field.memo.rawValue - 1 {
            return nil
        }
        
        let memo = row[Field.memo.rawValue]
        
        var index: Int?
        var count: Int?
        var parentMemo: String?
        var childMemo: String?
        
        let matches = regex.matches(in: memo, range: NSRange(location: 0, length: memo.count))
        if let match = matches.first {
            for i in 1..<match.numberOfRanges {
                let range = match.range(at: i)
                let startIndex = memo.index(memo.startIndex, offsetBy: range.location)
                let endIndex = memo.index(startIndex, offsetBy: range.length)
                let captureString = String(memo[startIndex..<endIndex])
                
                if i == 1 {
                    index = Int(captureString)
                } else if i == 2 {
                    count = Int(captureString)
                } else if i == 3 && captureString.count > 0 {
                    let split = captureString.components(separatedBy: " / ")
                    if split.count == 2 {
                        childMemo = split[0]
                        parentMemo = split[1]
                    } else {
                        parentMemo = captureString
                    }
                }
            }
        }
        
        if let index = index, let count = count {
            return SplitInfo(index: index, count: count, parentMemo: parentMemo, childMemo: childMemo)
        } else {
            return nil
        }
    }
}
