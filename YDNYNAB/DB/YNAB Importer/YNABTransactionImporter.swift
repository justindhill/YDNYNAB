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
        
        enum Field: Int {
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
        
        try! budgetContext.database.queue.write { db in

            var accounts: [String: Account] = [:]
            var payees: [String: Payee] = [:]
            
            guard let stream = InputStream(url: csvFileUrl) else {
                return
            }
            
            let csv = try CSVReader(stream: stream, hasHeaderRow: true, trimFields: true)
            
            while let row = csv.next() {
                let txn = Transaction()

                try! row.enumerated().forEach { index, value in
                    guard let field = Field(rawValue: index) else {
                        return
                    }

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
                        txn.account = account.id
                    case .flag:
                        txn.flag = Transaction.FlagColor(rawValue: value)
                    case .checkNumber:
                        txn.checkNumber = value
                    case .date:
                        if let date = self.dateFormatter.date(from: value) {
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
                        txn.payee = payee.id
                    case .masterCategory:
                        txn.masterCategory = BudgetMasterCategory.first(withName: value, inDb: db)?.id
                    case .subCategory:
                        if txn.masterCategory == YDNDatabase.IncomeCategoryId {
                            if value == "Available next month" {
                                let actualMonthYear = MonthYear(date: txn.date)
                                txn.effectiveDate = actualMonthYear.incrementingMonth().date
                            }
                            txn.subCategory = YDNDatabase.IncomeCategoryId
                        } else {
                            txn.subCategory = BudgetSubCategory.first(withName: value, inDb: db)?.id
                        }
                    case .memo:
                        txn.memo = value
                    case .outflow:
                        txn.outflow = self.currencyFormatter.number(from: value)?.doubleValue
                    case .inflow:
                        txn.inflow = self.currencyFormatter.number(from: value)?.doubleValue
                    case .cleared:
                        txn.cleared = (value != "U")

                    default:
                        break
                    }
                }

                try txn.insert(db)
            }
        }
    }
}
