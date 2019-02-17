//
//  RegisterViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB
import AppKit

class RegisterViewDataSource: NSObject, NSTableViewDataSource {
    
    private var dbQueue: DatabaseQueue
    
    var resultSet: [Transaction]?
    var filter: Filter? {
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
        var queryString =
            "SELECT `transaction`.*, budgetMasterCategory.name || ': ' || budgetSubCategory.name as categoryDisplayName, account.name as accountDisplayName, payee.name as payeeDisplayName " +
            "FROM `transaction` " +
            "LEFT JOIN account on `transaction`.account = account.id " +
            "LEFT JOIN payee on `transaction`.payee = payee.id " +
            "LEFT JOIN budgetSubCategory on `transaction`.subCategory = budgetSubCategory.id " +
            "LEFT JOIN budgetMasterCategory on `transaction`.masterCategory = budgetMasterCategory.id "

        var arguments: [Any] = []
        if let (filterString, filterArguments) = self.filter?.components {
            queryString += "\(filterString) "
            arguments = filterArguments
        }
        
        queryString += "ORDER BY date(`transaction`.date) DESC"
        
        self.resultSet = self.dbQueue.read { try! Transaction.fetchAll($0, queryString, arguments: StatementArguments(arguments)) }
    }

    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.resultSet?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.resultSet?[row]
    }

    // MARK: - RegisterViewController
    func text(forColumn columnIdentifier: RegisterViewController.ColumnIdentifier, row: Int) -> String? {
        guard let transaction = self.resultSet?[row] else {
            return nil
        }

        switch columnIdentifier {
        case .account:
            return transaction.accountDisplayName
        case .date:
            return DateUtils.dateString(withDate: transaction.date)
        case .payee:
            return transaction.payeeDisplayName
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
        
        guard let txn = self.resultSet?[row] else {
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
