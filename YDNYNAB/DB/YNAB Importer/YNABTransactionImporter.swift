//
//  YNABTransactionImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

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
        guard let fileContents = try? String(contentsOf: csvFileUrl) else {
            fatalError("Couldn't get file contents")
        }
        
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
            var skipLine = true

            var accounts: [String: Account] = [:]
            var payees: [String: Payee] = [:]

            try fileContents.split(separator: "\n").forEach { (line) in
                if skipLine {
                    skipLine = false
                    return
                }

                let txn = Transaction()

                let lineSplit = line.split(separator: ",", omittingEmptySubsequences: false)
                try! lineSplit.enumerated().forEach { (index, value) in
                    let stringValue = String(value).trimmingCharacters(in: ["\""])
                    guard let field = Field(rawValue: index) else {
                        return
                    }

                    switch field {
                    case .account:
                        let account: Account
                        if let existingAccount = accounts[stringValue] {
                            account = existingAccount
                        } else {
                            account = Account()
                            account.name = stringValue
                            try account.insert(db)
                            accounts[stringValue] = account
                        }
                        txn.account = account.id
                    case .flag:
                        txn.flag = FlagColor(rawValue: stringValue)
                    case .checkNumber:
                        txn.checkNumber = stringValue
                    case .date:
                        if let date = self.dateFormatter.date(from: stringValue) {
                            txn.date = date
                        }
                    case .payee:
                        let payee: Payee
                        if let existingPayee = payees[stringValue] {
                            payee = existingPayee
                        } else {
                            payee = Payee()
                            payee.name = stringValue
                            try payee.insert(db)
                            payees[stringValue] = payee
                        }
                        txn.payee = payee.id
                    case .masterCategory:
                        txn.masterCategory = BudgetMasterCategory.first(withName: stringValue, inDb: db)?.id
                    case .subCategory:
                        txn.subCategory = BudgetSubCategory.first(withName: stringValue, inDb: db)?.id
                    case .memo:
                        txn.memo = stringValue
                    case .outflow:
                        txn.outflow = self.currencyFormatter.number(from: stringValue)?.doubleValue
                    case .inflow:
                        txn.inflow = self.currencyFormatter.number(from: stringValue)?.doubleValue
                    case .cleared:
                        txn.cleared = (stringValue != "U")

                    default:
                        break
                    }
                }

                try txn.insert(db)
            }
        }
    }
}
