//
//  BudgetMonthSheetViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetMonthSheetViewController: NSViewController, NSOutlineViewDelegate {
    
    typealias MonthYear = (month: Int, year: Int)
    static let MonthYearZero = MonthYear(month: 0, year: 0)
    
    enum Constant {
        static let budgetedColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNBudgetMonthSheetViewBudgetedColumnIdentifier")
        static let outflowsColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNBudgetMonthSheetViewOutflowsColumnIdentifier")
        static let balanceColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNBudgetMonthSheetViewBalanceColumnIdentifier")
    }

    var tableDataSource = BudgetMonthTableDataSource(month: 0, year: 0, dbQueue: YDNDatabase.defaultQueue)
    
    var month: MonthYear = BudgetMonthSheetViewController.MonthYearZero {
        didSet { self.updateForMonth(month: month) }
    }
    
    override func loadView() {
        self.view = BudgetMonthSheetView()
    }
    
    var budgetSheetView: BudgetMonthSheetView {
        return self.view as! BudgetMonthSheetView
    }
    
    lazy var keyViewProvider: BudgetMonthSheetKeyViewProvider = BudgetMonthSheetKeyViewProvider(outlineView: self.budgetSheetView.outlineView)
    
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
        
        self.tableDataSource = BudgetMonthTableDataSource(month: month.month, year: month.year, dbQueue: YDNDatabase.defaultQueue)
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
        guard let item = item as? BudgetLine else {
            return nil
        }
        
        let reuseIdentifier = BudgetMonthCurrencyTableCellView.Constant.reuseIdentifier
        let cellView: BudgetMonthCurrencyTableCellView
        if let existingView = outlineView.makeView(withIdentifier: reuseIdentifier, owner: self) as? BudgetMonthCurrencyTableCellView {
            cellView = existingView
        } else {
            cellView = BudgetMonthCurrencyTableCellView()
            cellView.keyViewProvider = self.keyViewProvider
        }
        
        cellView.alignment = .right
        
        guard let tableColumn = tableColumn else {
            return cellView
        }
        
        if tableColumn.identifier == BudgetMonthSheetViewController.Constant.budgetedColumnIdentifier {
            cellView.mouseoverCursor = .iBeam
            cellView.editable = true
            
            if let budgeted = item.budgeted, let numberString = self.currencyFormatter.string(from: NSNumber(value: budgeted)) {
                if budgeted > 0 {
                    cellView.text = numberString
                }
            }
        } else if tableColumn.identifier == BudgetMonthSheetViewController.Constant.outflowsColumnIdentifier {
            cellView.mouseoverCursor = .pointingHand
            cellView.underlinesTextOnMouseover = true
            
            if let outflows = item.outflows, let numberString = self.currencyFormatter.string(from: NSNumber(value: -outflows)) {
                if outflows > 0 {
                    cellView.text = numberString
                }
            }
        } else if tableColumn.identifier == BudgetMonthSheetViewController.Constant.balanceColumnIdentifier {
            if let numberString = self.currencyFormatter.string(from: NSNumber(value: item.categoryBalance)) {
                cellView.text = numberString
            }
        }
        
        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {       
        return BudgetMonthTableRowView(row: outlineView.row(forItem: item))
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
        let outlineView = self.budgetSheetView.outlineView
        
        if outlineView.clickedColumn < 0 {
            return
        }
        
        let clickedCell = outlineView.view(atColumn: outlineView.clickedColumn, row: outlineView.clickedRow, makeIfNecessary: false)
        let column = outlineView.tableColumns[outlineView.clickedColumn]
        let subcategory = (outlineView.item(atRow: outlineView.clickedRow) as? BudgetLine)?.subcategory
        
        if let clickedCell = clickedCell, let subcategory = subcategory, column.identifier == Constant.outflowsColumnIdentifier {
            let (startDate, endDate) = DateUtils.startAndEndDate(ofMonth: self.month.month, year: self.month.year)
            let filter = RegisterViewDataSource.Filter(startDate: startDate, endDate: endDate, subcategory: subcategory)
            
            let register = RegisterViewController(mode: .popover)
            register.dataSource.filter = filter
            
            let popover = NSPopover()
            popover.contentViewController = register
            popover.contentSize = CGSize(width: 400, height: 200)
            popover.animates = true
            popover.behavior = .transient
            popover.show(relativeTo: clickedCell.bounds, of: clickedCell, preferredEdge: .maxY)
        }
    }
    
}

extension BudgetMonthSheetViewController: BudgetMonthCurrencyTableCellViewDelegate {
    
    func budgetCurrencyCell(_ cell: BudgetMonthCurrencyTableCellView, didCommitValue: Double?) {
        
    }
    
}
