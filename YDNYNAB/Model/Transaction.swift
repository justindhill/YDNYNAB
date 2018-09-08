//
//  Transaction.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class Transaction: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var account: Account?
    @objc dynamic var flag: String?
    @objc dynamic var checkNumber: String?
    @objc dynamic var date: Date = Date()
    @objc dynamic var payee: Payee?
    @objc dynamic var masterCategory: BudgetMasterCategory?
    @objc dynamic var subCategory: BudgetSubCategory?
    @objc dynamic var memo: String?
    let outflow = RealmOptional<Double>()
    let inflow = RealmOptional<Double>()
    @objc dynamic var cleared: Bool = false
}
