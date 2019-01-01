//
//  AppContext.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetContext: NSObject {
    
    let budgetWrapper: BudgetPackageWrapper
    let database: YDNDatabase
    let budgetUpdater: BudgetUpdater
    
    init(budgetWrapper: BudgetPackageWrapper) {
        self.budgetWrapper = budgetWrapper
        self.database = YDNDatabase(budgetWrapper: budgetWrapper)
        self.budgetUpdater = BudgetUpdater(dbQueue: self.database.queue)
        super.init()
    }

}
