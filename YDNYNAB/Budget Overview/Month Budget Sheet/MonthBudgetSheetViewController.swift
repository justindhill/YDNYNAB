//
//  MonthBudgetSheetViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSheetViewController: NSViewController, NSTableViewDelegate {
    
    private enum Constant {
        static let budgetedColumnIdentifier = "YDNMonthBudgetSheetViewBudgetedColumnIdentifier"
        static let outflowsColumnIdentifier = "YDNMonthBudgetSheetViewOutflowsColumnIdentifier"
        static let balanceColumnIdentifier = "YDNMonthBudgetSheetViewBalanceColumnIdentifier"
    }
    
    let tableDataSource = MonthBudgetTableDataSource()
    
    override func loadView() {
        self.view = MonthBudgetSheetView()
    }
    
    var budgetSheetView: MonthBudgetSheetView {
        return self.view as! MonthBudgetSheetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.budgetSheetView.detailsTableView.delegate = self
        self.budgetSheetView.detailsTableView.dataSource = self.tableDataSource
        self.addColumnsTo(table: self.budgetSheetView.detailsTableView)
    }
    
    func addColumnsTo(table: NSTableView) {
        let budgeted = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: Constant.budgetedColumnIdentifier))
        budgeted.title = "Budgeted"
        table.addTableColumn(budgeted)
        
        let outflows = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: Constant.outflowsColumnIdentifier))
        outflows.title = "Outflows"
        table.addTableColumn(outflows)
        
        let balance = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: Constant.balanceColumnIdentifier))
        balance.title = "Balance"
        table.addTableColumn(balance)
    }
    
}
