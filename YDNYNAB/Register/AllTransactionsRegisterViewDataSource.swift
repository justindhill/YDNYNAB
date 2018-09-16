//
//  AllTransactionsRegisterViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class AllTransactionsRegisterViewDataSource: NSObject, NSTableViewDataSource {
    
    var resultSet: Results<Transaction>?
    
    override init() {
        super.init()
        self.resultSet = try? Realm()
            .objects(Transaction.self)
            .sorted(by: [SortDescriptor(keyPath: "date", ascending: false)])
    }
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        return formatter
    }()
    
    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.resultSet?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
    
    // MARK: - RegisterViewController
    func text(forColumn columnIdentifier: RegisterViewController.ColumnIdentifier, row: Int) -> String? {
        guard let transaction = self.resultSet?[row] else {
                return nil
        }
        
        switch columnIdentifier {
        case .account:
            return transaction.account?.name
        case .date:
            return self.dateFormatter.string(from: transaction.date)
        case .payee:
            return transaction.payee?.name
        case .category:
            let masterName = transaction.masterCategory?.name ?? ""
            let subName = transaction.subCategory?.name ?? ""
            return "\(masterName): \(subName)"
        case .memo:
            return transaction.memo
        case .inflow:
            return self.currencyStringForRealmOptionalDouble(transaction.inflow)
        case .outflow:
            return self.currencyStringForRealmOptionalDouble(transaction.outflow)
        }
    }
    
    // MARK: - Utils
    private func currencyStringForRealmOptionalDouble(_ number: RealmOptional<Double>) -> String {
        if let unwrappedNumber = number.value {
            return self.currencyFormatter.string(from: NSNumber(value: unwrappedNumber)) ?? ""
        } else {
            return ""
        }
    }
    
}
