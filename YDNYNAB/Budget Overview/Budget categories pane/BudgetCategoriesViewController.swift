//
//  BudgetCategoriesViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetCategoriesViewController: NSViewController {
    
    enum Constant {
        static let columnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "BudgetCategoriesViewControllerColumnIdentifier")
    }
    
    let dataSource = BudgetCategoriesViewDataSource()
    
    var budgetCategoriesView: BudgetCategoriesView {
        return self.view as! BudgetCategoriesView
    }
    
    override func loadView() {
        self.view = BudgetCategoriesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addColumnsTo(table: self.budgetCategoriesView.outlineView)
        self.budgetCategoriesView.outlineView.delegate = self.dataSource
        self.budgetCategoriesView.outlineView.dataSource = self.dataSource
        self.budgetCategoriesView.outlineView.expandItem(nil, expandChildren: true)
    }
    
    func addColumnsTo(table: NSTableView) {
        let column = NSTableColumn(identifier: Constant.columnIdentifier)
        column.title = "Category"
        table.addTableColumn(column)
    }
    
}
