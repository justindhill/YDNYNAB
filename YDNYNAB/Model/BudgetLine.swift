//
//  BudgetLine.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class BudgetLine: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var month: Date = Date()
    @objc dynamic var masterCategory: BudgetMasterCategory?
    @objc dynamic var subCategory: BudgetSubCategory?
    let budgeted = RealmOptional<Double>()
    let outflows = RealmOptional<Double>()
    @objc dynamic var categoryBalance: Double = 0
}
