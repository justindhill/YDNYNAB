//
//  Transaction.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class Transaction: Record {
    var id: String = UUID().uuidString
    var account: Account?
    var flag: String?
    var checkNumber: String?
    var date: Date = Date()
    var payee: Payee?
    var masterCategory: BudgetMasterCategory?
    var subCategory: BudgetSubCategory?
    var memo: String?
    let outflow: Double = 0
    let inflow: Double = 0
    var cleared: Bool = false
}
