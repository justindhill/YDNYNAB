//
//  MonthBudgetTableDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import RealmSwift

class MonthBudgetTableDataSource: NSView, NSTableViewDelegate, NSTableViewDataSource {
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var resultSet: Results<BudgetLine>?
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let dateComponents = NSDateComponents()
        dateComponents.year = 2018
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.calendar = Calendar.current
        let startDate = dateComponents.date
        dateComponents.month = 2
        let endDate = dateComponents.date
        
        if let startDate = startDate, let endDate = endDate {
            self.resultSet = try? Realm()
                .objects(BudgetLine.self)
                .filter("month >= %@ AND month < %@ AND masterCategory.name != 'Hidden Categories'", startDate, endDate)
        }
        

    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.resultSet?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let resultSet = self.resultSet, let tableColumn = tableColumn else {
            return nil
        }            
        
        let budgetLine = resultSet[row]
        
        let cellView = MonthBudgetCurrencyTableCellView()
        if tableColumn.identifier == MonthBudgetSheetViewController.Constant.budgetedColumnIdentifier {
            if let budgetedValue = budgetLine.budgeted.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: budgetedValue)) {
                cellView.currencyTextField.stringValue = numberString
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.outflowsColumnIdentifier {
            if let outflowsValue = budgetLine.outflows.value, let numberString = self.currencyFormatter.string(from: NSNumber(value: outflowsValue)) {
                cellView.currencyTextField.stringValue = numberString
            }
        } else if tableColumn.identifier == MonthBudgetSheetViewController.Constant.balanceColumnIdentifier {
            cellView.currencyTextField.stringValue = ""
        }
        
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MonthBudgetTableRowView(row: row)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}
