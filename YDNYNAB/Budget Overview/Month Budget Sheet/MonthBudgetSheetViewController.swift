//
//  MonthBudgetSheetViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSheetViewController: NSViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.budgetSheetView.detailsTableView.delegate = self.tableDataSource
        self.budgetSheetView.detailsTableView.dataSource = self.tableDataSource
        self.addColumnsTo(table: self.budgetSheetView.detailsTableView)
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
    
}
