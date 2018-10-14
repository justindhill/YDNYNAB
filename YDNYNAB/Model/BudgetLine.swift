//
//  BudgetLine.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetLine: Record {
    var id: String = UUID().uuidString
    var month: Date = Date()
    var masterCategory: BudgetMasterCategory?
    var subCategory: BudgetSubCategory?
    let budgeted: Double = 0
    let outflows: Double = 0
    var categoryBalance: Double = 0
}
