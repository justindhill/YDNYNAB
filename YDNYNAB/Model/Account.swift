//
//  Account.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class Account: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var name: String = ""
    var accountId: String?
}
