//
//  AppContext.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class AppContext: NSObject {
    
    let budgetUpdater = BudgetUpdater(dbQueue: YDNDatabase.defaultQueue)

}
