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
    
    private var currentRegisterPopover: NSPopover?
    
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
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.budgetSheetView.outlineView.delegate = self
        self.addColumnsToOutlineView()
        
        self.budgetSheetView.outlineView.target = self
        self.budgetSheetView.outlineView.action = #selector(clickAction)
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
        let reuseIdentifier = MonthBudgetCurrencyTableCellView.Constant.reuseIdentifier
        let cellView: MonthBudgetCurrencyTableCellView
        if let existingView = outlineView.makeView(withIdentifier: reuseIdentifier, owner: self) as? MonthBudgetCurrencyTableCellView {
            cellView = existingView
        } else {
            cellView = MonthBudgetCurrencyTableCellView()
        }
        
        cellView.alignment = .right
        
        guard let tableColumn = tableColumn else {
            return cellView
        }
        
        if tableColumn.identifier == MonthBudgetSheetViewController.Constant.budgetedColumnIdentifier {
            cellView.mouseoverCursor = .iBeam
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.outflowsColumnIdentifier {
            cellView.mouseoverCursor = .pointingHand
            cellView.underlinesTextOnMouseover = true
        }
        
        guard let item = item as? BudgetLine else {
            return cellView
        }
        
        if tableColumn.identifier == MonthBudgetSheetViewController.Constant.budgetedColumnIdentifier {
            if let budgetedValue = item.budgeted.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: budgetedValue)) {
                if budgetedValue > 0 {
                    cellView.text = numberString
                }
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.outflowsColumnIdentifier {
            if let outflowsValue = item.outflows.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: -outflowsValue)) {
                if outflowsValue > 0 {
                    cellView.text = numberString
                }
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.balanceColumnIdentifier {
            if let numberString = self.currencyFormatter.string(from: NSNumber(value: item.categoryBalance)) {
                cellView.text = numberString
            }
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
    
    @objc func clickAction() {
        if let popover = self.currentRegisterPopover {
            popover.performClose(self)
            self.currentRegisterPopover = nil
        }
        
        let outlineView = self.budgetSheetView.outlineView
        
        if outlineView.clickedColumn < 0 {
            return
        }
        
        let clickedCell = outlineView.view(atColumn: outlineView.clickedColumn, row: outlineView.clickedRow, makeIfNecessary: false)
        let column = outlineView.tableColumns[outlineView.clickedColumn]
        let subcategory = (outlineView.item(atRow: outlineView.clickedRow) as? BudgetLine)?.subCategory
        
        if let clickedCell = clickedCell, let subcategory = subcategory, column.identifier == Constant.outflowsColumnIdentifier {
            let (startDate, endDate) = DateUtils.startAndEndDate(ofMonth: self.month.month, year: self.month.year)
            let filter = RegisterViewDataSource.Filter(startDate: startDate, endDate: endDate, subcategory: subcategory)
            
            let register = RegisterViewController(mode: .popover)
            register.dataSource.filter = filter
            
            let popover = NSPopover()
            popover.contentViewController = register
            popover.contentSize = CGSize(width: 400, height: 200)
            popover.animates = true
            popover.show(relativeTo: clickedCell.bounds, of: clickedCell, preferredEdge: .maxY)
            self.currentRegisterPopover = popover
        }
    }
}
