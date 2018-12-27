//
//  BudgetLine.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetLine: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    var id: Int64?
    var month: Date = Date()
    var masterCategory: Int64?
    var subcategory: Int64?
    var budgeted: Double?
    var outflows: Double?
    var categoryBalance: Double = 0
    var carriesOverNegativeBalance = false
}
