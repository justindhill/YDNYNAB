//
//  YNABTransactionImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class YNABTransactionImporter {
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter
    }()
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    init(csvFileUrl: URL) {
        guard let fileContents = try? String(contentsOf: csvFileUrl) else {
            fatalError("Couldn't get file contents")
        }
        
        guard let realm = try? Realm() else {
            fatalError("Couldn't get the default realm")
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
        
        try! realm.write {
            var skipLine = true
            
            var accounts: [String: Account] = [:]
            var payees: [String: Payee] = [:]
            
            fileContents.split(separator: "\n").forEach { (line) in
                if skipLine {
                    skipLine = false
                    return
                }
                
                let txn = realm.create(Transaction.self)
                
                let lineSplit = line.split(separator: ",", omittingEmptySubsequences: false)
                lineSplit.enumerated().forEach { (index, value) in
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
                            account = realm.create(Account.self)
                            account.name = stringValue
                            accounts[stringValue] = account
                        }
                        txn.account = account
                    case .flag:
                        txn.flag = stringValue
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
                            payee = realm.create(Payee.self)
                            payee.name = stringValue
                            payees[stringValue] = payee
                        }
                        txn.payee = payee
                    case .masterCategory:
                        txn.masterCategory = realm.objects(BudgetMasterCategory.self)
                            .filter("name = %@", stringValue)
                            .first
                    case .subCategory:
                        txn.subCategory = realm.objects(BudgetSubCategory.self)
                            .filter("name = %@", stringValue)
                            .first
                    case .memo:
                        txn.memo = stringValue
                    case .outflow:
                        txn.outflow.value = self.currencyFormatter.number(from: stringValue)?.doubleValue
                    case .inflow:
                        txn.inflow.value = self.currencyFormatter.number(from: stringValue)?.doubleValue
                    case .cleared:
                        txn.cleared = (stringValue != "U")
                        
                    default:
                        break
                    }
                }
                
                realm.add(txn)
            }
        }
    }
}
