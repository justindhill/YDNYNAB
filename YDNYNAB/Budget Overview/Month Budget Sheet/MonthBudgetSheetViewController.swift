//
//  MonthBudgetSheetViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSheetViewController: NSViewController, NSOutlineViewDelegate {
    
    typealias MonthYear = (month: Int, year: Int)
    static let MonthYearZero = MonthYear(month: 0, year: 0)
    
    enum Constant {
        static let budgetedColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewBudgetedColumnIdentifier")
        static let outflowsColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewOutflowsColumnIdentifier")
        static let balanceColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNMonthBudgetSheetViewBalanceColumnIdentifier")
    }
    
    var tableDataSource = MonthBudgetTableDataSource(month: 0, year: 0)
    
    var month: MonthYear = MonthBudgetSheetViewController.MonthYearZero {
        didSet { self.updateForMonth(month: month) }
    }
    
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
        self.addColumnsToOutlineView()
    }
    
    func updateForMonth(month: MonthYear) {
        self.budgetSheetView.summaryView.updateForMonth(month: month)
        
        self.tableDataSource = MonthBudgetTableDataSource(month: month.month, year: month.year)
        self.budgetSheetView.outlineView.dataSource = self.tableDataSource
        self.budgetSheetView.outlineView.reloadData()
        self.budgetSheetView.outlineView.expandItem(nil, expandChildren: true)
    }
    
    func addColumnsToOutlineView() {
        let outlineView = self.budgetSheetView.outlineView
        
        let budgeted = NSTableColumn(identifier: Constant.budgetedColumnIdentifier)
        budgeted.title = "Budgeted"
        outlineView.addTableColumn(budgeted)
        
        let outflows = NSTableColumn(identifier: Constant.outflowsColumnIdentifier)
        outflows.title = "Outflows"
        outlineView.addTableColumn(outflows)
        
        let balance = NSTableColumn(identifier: Constant.balanceColumnIdentifier)
        balance.title = "Balance"
        outlineView.addTableColumn(balance)
    }
    
    // MARK: - NSOutlineViewDelegate
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? BudgetLine, let tableColumn = tableColumn else {
            return nil
        }
        
        let reuseIdentifier = MonthBudgetCurrencyTableCellView.Constant.reuseIdentifier
        let cellView: MonthBudgetCurrencyTableCellView
        if let existingView = outlineView.makeView(withIdentifier: reuseIdentifier, owner: self) as? MonthBudgetCurrencyTableCellView {
            cellView = existingView
        } else {
            cellView = MonthBudgetCurrencyTableCellView()
        }
        
        cellView.alignment = .right
        if tableColumn.identifier == MonthBudgetSheetViewController.Constant.budgetedColumnIdentifier {
            if let budgetedValue = item.budgeted.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: budgetedValue)) {
                cellView.text = numberString
                cellView.mouseoverCursor = .iBeam
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.outflowsColumnIdentifier {
            if let outflowsValue = item.outflows.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: outflowsValue)) {
                cellView.text = numberString
                cellView.mouseoverCursor = .pointingHand
                cellView.underlinesTextOnMouseover = true
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.balanceColumnIdentifier {
            cellView.text = ""
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {       
        return MonthBudgetTableRowView(row: outlineView.row(forItem: item))
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
        return true
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
