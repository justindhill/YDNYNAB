//
//  BudgetSubcategory.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetSubCategory: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var name: String = ""
    var sortOrder: Int = -1
    var masterCategory: Int64?
    var isHidden: Bool = false
    
}
