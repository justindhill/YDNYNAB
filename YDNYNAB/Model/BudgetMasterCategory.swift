//
//  BudgetMasterCategory.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class BudgetMasterCategory: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    let subcategories = LinkingObjects(fromType: BudgetSubCategory.self, property: "masterCategory")
}
