//
//  Payee.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class Payee: Record {
    var id: String = UUID().uuidString
    var name: String = ""
    var defaultMasterCategory: BudgetMasterCategory?
    var defualtSubCategory: BudgetSubCategory?
}
