//
//  MonthBudgetTableDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetTableDataSource: NSView, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 250
    }
    
}
