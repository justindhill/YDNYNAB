//
//  Transaction.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

extension FlagColor: DatabaseValueConvertible {}
enum FlagColor: String, Codable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
}

class Transaction: NSObject, Codable, FetchableRecord, PersistableRecord {

    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var account: Int64?
    var flag: FlagColor?
    var checkNumber: String?
    var date: Date = Date()
    var payee: Int64?
    var masterCategory: Int64?
    var subCategory: Int64?
    var memo: String?
    var outflow: Double?
    var inflow: Double?
    var cleared: Bool = false
    
}
