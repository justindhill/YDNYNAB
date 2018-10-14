//
//  BudgetSubcategory.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetSubCategory: Record {
    var id: String = UUID().uuidString
    var name: String = ""
    var sortOrder: Int = -1
    var masterCategory: BudgetMasterCategory?
//    let budgetLines = LinkingObjects(fromType: BudgetLine.self, property: "subCategory")
    var isHidden: Bool = false
}
