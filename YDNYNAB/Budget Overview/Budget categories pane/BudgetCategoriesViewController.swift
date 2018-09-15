//
//  BudgetCategoriesViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol BudgetCategoriesViewControllerDelegate: class {
    func budgetCategoriesViewController(_ viewController: BudgetCategoriesViewController, willExpandRow row: Int)
    func budgetCategoriesViewController(_ viewController: BudgetCategoriesViewController, willCollapseRow row: Int)
}

class BudgetCategoriesViewController: NSViewController, NSOutlineViewDelegate {
    
    enum Constant {
        static let columnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "BudgetCategoriesViewControllerColumnIdentifier")
    }
    
    weak var delegate: BudgetCategoriesViewControllerDelegate?
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
        self.budgetCategoriesView.outlineView.delegate = self
        self.budgetCategoriesView.outlineView.dataSource = self.dataSource
        self.budgetCategoriesView.outlineView.expandItem(nil, expandChildren: true)
    }
    
    func addColumnsTo(table: NSTableView) {
        let column = NSTableColumn(identifier: Constant.columnIdentifier)
        column.title = "Category"
        table.addTableColumn(column)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = MonthBudgetCurrencyTableCellView()
        if let item = item as? BudgetMasterCategory {
            cellView.currencyTextField.stringValue = item.name
            cellView.currencyTextField.font = NSFont.boldSystemFont(ofSize: 12)
            
        } else if let item = item as? BudgetSubCategory {
            cellView.currencyTextField.stringValue = item.name
            cellView.currencyTextField.font = NSFont.systemFont(ofSize: 12)
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is BudgetMasterCategory {
            return 28
        } else {
            return 22
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MonthBudgetTableRowView(row: outlineView.row(forItem: item))
        if item is BudgetMasterCategory {
            rowView.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.25)
        }
        
        return rowView
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is BudgetMasterCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        guard let item = item as? BudgetMasterCategory else {
            return false
        }
        
        let row = self.budgetCategoriesView.outlineView.childIndex(forItem: item)
        self.delegate?.budgetCategoriesViewController(self, willExpandRow: row)
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        guard let item = item as? BudgetMasterCategory else {
            return false
        }
        
        let row = self.budgetCategoriesView.outlineView.childIndex(forItem: item)
        self.delegate?.budgetCategoriesViewController(self, willCollapseRow: row)
        return true
    }
    
}
