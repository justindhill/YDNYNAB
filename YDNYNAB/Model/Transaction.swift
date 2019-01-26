//
//  Transaction.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class Transaction: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    enum FlagColor: String, Codable {
        case red
        case orange
        case yellow
        case green
        case blue
        case purple
    }

    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var account: Int64?
    var flag: FlagColor?
    var checkNumber: String?
    var date: Date = Date()
    var effectiveDate: Date = Date()
    var payee: Int64?
    var masterCategory: Int64?
    var subCategory: Int64?
    var memo: String?
    var outflow: Double?
    var inflow: Double?
    var cleared: Bool = false
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["account"] = account
        container["flag"] = flag
        container["checkNumber"] = checkNumber
        container["date"] = date
        container["effectiveDate"] = effectiveDate
        container["payee"] = payee
        container["masterCategory"] = masterCategory
        container["subCategory"] = subCategory
        container["memo"] = memo
        container["outflow"] = outflow
        container["inflow"] = inflow
        container["cleared"] = cleared
    }
    
    // from joins, not encoded
    var accountDisplayName: String?
    var payeeDisplayName: String?
    var categoryDisplayName: String?
}

extension Transaction.FlagColor: DatabaseValueConvertible {}
