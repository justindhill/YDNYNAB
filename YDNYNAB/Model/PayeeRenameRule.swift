//
//  PayeeRenameRule.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/5/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import GRDB


class PayeeRenameRule: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    enum RuleType: String, Codable {
        case beginsWith
        case endsWith
        case contains
    }

    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var type: RuleType
    var criterion: String
    
    init(type: RuleType = .beginsWith, criterion: String) {
        self.type = type
        self.criterion = criterion
        super.init()
    }
    
}

extension PayeeRenameRule.RuleType: DatabaseValueConvertible {}
