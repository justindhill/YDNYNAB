//
//  MonthBudgetSheetViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSheetViewController: NSViewController, NSOutlineViewDelegate {
    
    enum Constant {
        static let budgetedColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewBudgetedColumnIdentifier")
        static let outflowsColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewOutflowsColumnIdentifier")
        static let balanceColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewBalanceColumnIdentifier")
    }
    
    let tableDataSource = MonthBudgetTableDataSource()
    
    override func loadView() {
        self.view = MonthBudgetSheetView()
    }
    
    var budgetSheetView: MonthBudgetSheetView {
        return self.view as! MonthBudgetSheetView
    }
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.budgetSheetView.outlineView.delegate = self
        self.budgetSheetView.outlineView.dataSource = self.tableDataSource
        self.addColumnsTo(table: self.budgetSheetView.outlineView)
        self.budgetSheetView.outlineView.expandItem(nil, expandChildren: true)
    }
    
    func addColumnsTo(table: NSTableView) {
        let budgeted = NSTableColumn(identifier: Constant.budgetedColumnIdentifier)
        budgeted.title = "Budgeted"
        table.addTableColumn(budgeted)
        
        let outflows = NSTableColumn(identifier: Constant.outflowsColumnIdentifier)
        outflows.title = "Outflows"
        table.addTableColumn(outflows)
        
        let balance = NSTableColumn(identifier: Constant.balanceColumnIdentifier)
        balance.title = "Balance"
        table.addTableColumn(balance)
    }
    
    // MARK: - NSOutlineViewDelegate
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? BudgetLine, let tableColumn = tableColumn else {
            return nil
        }
        
        let cellView = MonthBudgetCurrencyTableCellView()
        cellView.currencyTextField.cell?.alignment = .right
        if tableColumn.identifier == MonthBudgetSheetViewController.Constant.budgetedColumnIdentifier {
            if let budgetedValue = item.budgeted.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: budgetedValue)) {
                cellView.currencyTextField.stringValue = numberString
                cellView.currencyTextField.isEditable = true
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.outflowsColumnIdentifier {
            if let outflowsValue = item.outflows.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: outflowsValue)) {
                cellView.currencyTextField.stringValue = numberString
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.balanceColumnIdentifier {
            cellView.currencyTextField.stringValue = ""
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MonthBudgetTableRowView(row: outlineView.row(forItem: item))
        if item is BudgetMasterCategory {
            rowView.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.25)
        }
        
        return rowView
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is BudgetMasterCategory {
            return 28
        } else {
            return 22
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is BudgetMasterCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
    
    // MARK: - Utils
    func collapse(row: Int) {
        if let category = self.budgetSheetView.outlineView.child(row, ofItem: nil) as? BudgetMasterCategory {
            self.budgetSheetView.outlineView.animator().collapseItem(category, collapseChildren: true)
        }
    }
    
    func expand(row: Int) {
        if let category = self.budgetSheetView.outlineView.child(row, ofItem: nil) as? BudgetMasterCategory {
            self.budgetSheetView.outlineView.animator().expandItem(category, expandChildren: true)
        }
    }
    
}
