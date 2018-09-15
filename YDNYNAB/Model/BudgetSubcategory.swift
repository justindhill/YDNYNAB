//
//  BudgetSubcategory.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class BudgetSubCategory: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var masterCategory: BudgetMasterCategory?
    let budgetLines = LinkingObjects(fromType: BudgetLine.self, property: "subCategory")
    @objc dynamic var isHidden: Bool = false
}
