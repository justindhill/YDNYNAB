//
//  RegisterViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB
import AppKit

class RegisterViewDataSource: NSObject, NSOutlineViewDataSource {
    
    private var dbQueue: DatabaseQueue
    
    var topLevelTransactions: [Transaction]?
    var splitChildren: [Int64: [Transaction]] = [:]
    var filter: Transaction.Filter? {
        didSet { self.updateResultSet() }
    }

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
        
        super.init()
        
        self.updateResultSet()
    }

    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter
    }()

    func updateResultSet() {
        do {
            let results = try self.dbQueue.read { try Transaction.allTransactionsAndSplits(filter: filter, db: $0) }
            self.topLevelTransactions = results.transactions
            self.splitChildren = results.splits
        } catch {
            Toaster.shared.enqueueDefaultErrorToast()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return self.topLevelTransactions?.count ?? 0
        } else if let transaction = item as? Transaction, let id = transaction.id {
            return self.splitChildren[id]?.count ?? 0
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let transaction = item as? Transaction else {
            return false
        }
        
        if transaction.masterCategory == YDNDatabase.SplitCategoryId {
            return true
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil, let transaction = self.topLevelTransactions?[index] {
            return transaction
        } else if let transaction = item as? Transaction, let id = transaction.id, let child = self.splitChildren[id]?[index] {
            return child
        }
        
        assertionFailure("Something weird is going on with the data source")
        return NSObject()
    }

    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.topLevelTransactions?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.topLevelTransactions?[row]
    }

    // MARK: - RegisterViewController
    func text(forColumn columnIdentifier: RegisterViewController.ColumnIdentifier, transaction: Transaction) -> String? {
        switch columnIdentifier {
        case .account:
            return transaction.splitParent == nil ? transaction.accountDisplayName : ""
        case .date:
            return transaction.splitParent == nil ? DateUtils.dateString(withDate: transaction.date) : ""
        case .payee:
            return transaction.splitParent == nil ? transaction.payeeDisplayName : ""
        case .category:
            return transaction.categoryDisplayName
        case .memo:
            return transaction.memo
        case .inflow:
            if let inflow = transaction.inflow, inflow > 0 {
                return self.currencyFormatter.string(from: NSNumber(value: inflow))
            } else {
                return ""
            }
        case .outflow:
            if let outflow = transaction.outflow, outflow > 0 {
                return self.currencyFormatter.string(from: NSNumber(value: outflow))
            } else {
                return ""
            }
        }
    }

    func updateTransaction(forRow row: Int, inTableView tableView: NSTableView, withRowView rowView: NSTableRowView) throws {
        
        guard let txn = self.topLevelTransactions?[row] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        try RegisterViewController.ColumnIdentifier.allCases.forEach { columnIdentifier in
            let columnIndex = tableView.column(withIdentifier: columnIdentifier.userInterfaceIdentifier)
            guard let cellView = rowView.view(atColumn: columnIndex) as? RegisterCell else {
                throw NSError(domain: "", code: 0, userInfo: nil)
            }

            switch columnIdentifier {
            case .memo:
                txn.memo = cellView.inputTextField.stringValue
            case .inflow:
                txn.inflow = cellView.inputTextField.doubleValue
            case .outflow:
                txn.outflow = self.currencyFormatter.number(from: cellView.inputTextField.stringValue)?.doubleValue
            default:
                break
            }
        }
        
        try self.dbQueue.write { db -> Void in
            try txn.update(db)
        }
    }
    
}
