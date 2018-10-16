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

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        return formatter
    }()

    func updateResultSet() {
        self.resultSet = self.dbQueue.read { try? Transaction.order(sql: "date(date) DESC").fetchAll($0) }

//        if let filter = self.filter {
//            resultSet = resultSet?.filter(filter.filterPredicate)
//        }
//
//        resultSet = resultSet?.sorted(by: [SortDescriptor(keyPath: "date", ascending: false)])

//        self.resultSet = resultSet
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
            return "\(transaction.account)"
        case .date:
            return self.dateFormatter.string(from: transaction.date)
        case .payee:
            return "\(transaction.payee)"
        case .category:
            let masterName = "\(transaction.masterCategory)"
            let subName = "\(transaction.subCategory)"
            return "\(masterName): \(subName)"
        case .memo:
            return transaction.memo
        case .inflow:
            if let inflow = transaction.inflow {
                return self.currencyFormatter.string(from: NSNumber(value: inflow))
            } else {
                return ""
            }
        case .outflow:
            if let outflow = transaction.outflow {
                return self.currencyFormatter.string(from: NSNumber(value: outflow))
            } else {
                return ""
            }
        }
    }

    func updateTransaction(forRow row: Int, inTableView tableView: NSTableView, withRowView rowView: NSTableRowView) throws {
//        try Realm().write {
//            guard let txn = self.resultSet?[row] else {
//                throw NSError(domain: "", code: 0, userInfo: nil)
//            }
//
//            try RegisterViewController.ColumnIdentifier.allCases.forEach { columnIdentifier in
//                let columnIndex = tableView.column(withIdentifier: columnIdentifier.userInterfaceIdentifier)
//                guard let cellView = rowView.view(atColumn: columnIndex) as? RegisterCell else {
//                        throw NSError(domain: "", code: 0, userInfo: nil)
//                }
//
//                switch columnIdentifier {
//                case .memo:
//                    txn.memo = cellView.inputTextField.stringValue
//                case .inflow:
//                    txn.inflow.value = cellView.inputTextField.doubleValue
//                case .outflow:
//                    txn.outflow.value = self.currencyFormatter.number(from: cellView.inputTextField.stringValue)?.doubleValue
//                default:
//                    break
//                }
//            }
//        }
    }
//
//    // MARK: - Utils
//    private func currencyStringForRealmOptionalDouble(_ number: RealmOptional<Double>) -> String {
//        if let unwrappedNumber = number.value {
//            return self.currencyFormatter.string(from: NSNumber(value: unwrappedNumber)) ?? ""
//        } else {
//            return ""
//        }
//    }
    
}
