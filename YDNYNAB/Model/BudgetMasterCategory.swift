//
//  BudgetMasterCategory.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetMasterCategory: Record {
    var id: String = UUID().uuidString
    var name: String = ""
    var sortOrder: Int = -1
//    let subcategories = LinkingObjects(fromType: BudgetSubCategory.self, property: "masterCategory")
    
//    var visibleSubcategories: Results<BudgetSubCategory> {
//        return self.subcategories.filter("isHidden = %@", false)
//    }
}
