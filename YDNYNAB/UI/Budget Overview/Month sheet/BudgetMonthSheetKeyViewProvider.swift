//
//  BudgetMonthSheetKeyViewProvider.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetMonthSheetKeyViewProvider: NSObject, BudgetMonthCurrencyTableCellViewKeyViewProvider {
    let outlineView: NSOutlineView
    
    init(outlineView: NSOutlineView) {
        self.outlineView = outlineView
        super.init()
    }
    
    func nextKeyView(for view: BudgetMonthCurrencyTableCellView) -> YDNTextField? {
        guard let rowView = view.rowView as? BudgetMonthTableRowView else {
            return nil
        }
        
        let numberOfRows = self.outlineView.numberOfRows
        let column = self.outlineView.column(for: view)
        
        var nextRow = rowView.row + 1
        while 0..<numberOfRows ~= nextRow {
            if let textField = self.textFieldForRow(row: nextRow, column: column) {
                self.outlineView.scrollRowToVisible(nextRow)
                return textField
            }
            nextRow += 1
        }
        
        self.outlineView.scrollToBeginningOfDocument(self)
        return self.textFieldForRow(row: 0, column: column)
    }
    
    func previousKeyView(for view: BudgetMonthCurrencyTableCellView) -> YDNTextField? {
        guard let rowView = view.rowView as? BudgetMonthTableRowView else {
            return nil
        }
        
        let numberOfRows = self.outlineView.numberOfRows
        let column = self.outlineView.column(for: view)
        
        var previousRow = rowView.row - 1
        while 0..<numberOfRows ~= previousRow {
            if let textField = self.textFieldForRow(row: previousRow, column: column) {
                self.outlineView.scrollRowToVisible(previousRow)
                return textField
            }
            previousRow -= 1
        }
        
        self.outlineView.scrollToEndOfDocument(self)
        return self.textFieldForRow(row: numberOfRows - 1, column: column)
    }
    
    func textFieldForRow(row: Int, column: Int) -> YDNTextField? {
        let cell = self.outlineView.view(atColumn: column, row: row, makeIfNecessary: true)
        if let cell = cell as? BudgetMonthCurrencyTableCellView {
            return cell.editingTextField
        }
        
        return nil
    }
}
