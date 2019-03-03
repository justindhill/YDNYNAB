//
//  Transaction+Queries.swift
//  YDNYNAB
//
//  Created by Justin Hill on 3/3/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa
import GRDB

typealias TransactionsAndSplits = (transactions: [Transaction], splits: [Int64: [Transaction]])

extension Transaction {
    
    class func allTransactionsAndSplits(filter: Filter? = nil, db: Database) throws -> TransactionsAndSplits {
        var queryString =
            "SELECT `transaction`.*, budgetMasterCategory.name || ': ' || budgetSubCategory.name as categoryDisplayName, account.name as accountDisplayName, payee.name as payeeDisplayName " +
                "FROM `transaction` " +
                "LEFT JOIN account on `transaction`.account = account.id " +
                "LEFT JOIN payee on `transaction`.payee = payee.id " +
                "LEFT JOIN budgetSubCategory on `transaction`.subCategory = budgetSubCategory.id " +
                "LEFT JOIN budgetMasterCategory on `transaction`.masterCategory = budgetMasterCategory.id "
        
        
        var arguments: [Any] = []
        if let (filterString, filterArguments) = filter?.components {
            queryString += "\(filterString) "
            arguments = filterArguments
        }
        
        queryString += "ORDER BY date(`transaction`.date) DESC"
        
        var topLevelTransactions: [Transaction] = []
        var splitChildren: [Int64: [Transaction]] = [:]

        try Transaction.fetchCursor(db, queryString, arguments: StatementArguments(arguments)).forEach { transaction in
            if let splitParent = transaction.splitParent {
                var splitList = splitChildren[splitParent] ?? []
                splitList.append(transaction)
                splitChildren[splitParent] = splitList
            } else {
                topLevelTransactions.append(transaction)
            }
        }
        
        return TransactionsAndSplits(transactions: topLevelTransactions, splits: splitChildren)
    }
    
}
