//
//  RegisterViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController, NSTableViewDelegate, RegisterRowViewDelegate {
    
    enum ColumnIdentifier: String, CaseIterable {
        case account = "YDNMonthRegisterViewAccountColumnIdentifier"
        case date = "YDNMonthRegisterViewDateColumnIdentifier"
        case payee = "YDNMonthRegisterViewAccountPayeeIdentifier"
        case category = "YDNMonthRegisterViewCategoryColumnIdentifier"
        case memo = "YDNMonthRegisterViewMemoColumnIdentifier"
        case outflow = "YDNMonthRegisterViewOutflowColumnIdentifier"
        case inflow = "YDNMonthRegisterViewInflowColumnIdentifier"
        
        var userInterfaceIdentifier: NSUserInterfaceItemIdentifier {
            return NSUserInterfaceItemIdentifier(rawValue: self.rawValue)
        }
    }
    
    override func loadView() {
        self.view = RegisterView()
    }
    
    var registerView: RegisterView {
        return self.view as! RegisterView
    }
    
    let dataSource = AllTransactionsRegisterViewDataSource()
    
    var focusedRow: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addColumnsToTableView()
        self.registerView.tableView.delegate = self
        self.registerView.tableView.dataSource = self.dataSource
        
        self.registerView.tableScrollView.hasVerticalScroller = true
    }
    
    func addColumnsToTableView() {
        let tableView = self.registerView.tableView
        
        tableView.addTableColumn(withTitle: "Account",
                                 identifier: ColumnIdentifier.account.userInterfaceIdentifier,
                                 initialWidth: 140)
        tableView.addTableColumn(withTitle: "Date",
                                 identifier: ColumnIdentifier.date.userInterfaceIdentifier,
                                 initialWidth: 70)
        tableView.addTableColumn(withTitle: "Payee",
                                 identifier: ColumnIdentifier.payee.userInterfaceIdentifier,
                                 resizingOptions: .autoresizingMask)
        tableView.addTableColumn(withTitle: "Category",
                                 identifier: ColumnIdentifier.category.userInterfaceIdentifier,
                                 resizingOptions: .autoresizingMask)
        tableView.addTableColumn(withTitle: "Memo",
                                 identifier: ColumnIdentifier.memo.userInterfaceIdentifier,
                                 resizingOptions: .autoresizingMask)
        tableView.addTableColumn(withTitle: "Inflow",
                                 identifier: ColumnIdentifier.inflow.userInterfaceIdentifier,
                                 initialWidth: 70)
        tableView.addTableColumn(withTitle: "Outflow",
                                 identifier: ColumnIdentifier.outflow.userInterfaceIdentifier,
                                 initialWidth: 70)
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = RegisterRowView()
        rowView.delegate = self
        
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else {
            return nil
        }
        
        let view: RegisterCell
        if let reusedView = tableView.makeView(withIdentifier: tableColumn.identifier, owner: self) {
            view = reusedView as! RegisterCell
        } else {
            view = RegisterCell()
            view.identifier = tableColumn.identifier
        }
        
        if let columnIdentifier = ColumnIdentifier(rawValue: tableColumn.identifier.rawValue) {
            view.text = self.dataSource.text(forColumn: columnIdentifier, row: row)
            view.alignment = self.textAlignment(forColumnIdentifier: columnIdentifier)
        }
        
        return view
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let newSelectedRow = self.registerView.tableView.selectedRow
        var rows = IndexSet()
        
        if let focusedRow = self.focusedRow {
            let rowView = self.registerView.tableView.rowView(atRow: focusedRow, makeIfNecessary: false) as? RegisterRowView
            rowView?.isEditing = false
            rows.insert(focusedRow)
        }
        
        if newSelectedRow >= 0 {
            let newSelectedRowView = self.registerView.tableView.rowView(atRow: newSelectedRow, makeIfNecessary: false) as? RegisterRowView
            newSelectedRowView?.isEditing = true
            rows.insert(newSelectedRow)
            self.focusedRow = self.registerView.tableView.selectedRow
        } else {
            self.focusedRow = nil
        }
        
        self.registerView.tableView.noteHeightOfRows(withIndexesChanged: rows)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == self.registerView.tableView.selectedRow {
            return RegisterRowView.Constant.expandedHeight
        } else {
            return RegisterRowView.Constant.collapsedHeight
        }
    }
    
    func textAlignment(forColumnIdentifier columnIdentifier: ColumnIdentifier) -> NSTextAlignment {
        switch columnIdentifier {
        case .inflow, .outflow:
            return .right
        default:
            return .left
        }
    }
    
    // MARK: - RegisterRowViewDelegate
    func registerRowViewDidCommitChanges(_ rowView: RegisterRowView) {
        guard let focusedRow = self.focusedRow else {
            return
        }
        
        let row = self.registerView.tableView.row(for: rowView)
        if row != -1 {
            do {
                try self.dataSource.updateTransaction(forRow: row, inTableView: self.registerView.tableView, withRowView: rowView)
                self.registerView.tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(0..<ColumnIdentifier.allCases.count))
            } catch {
                Toaster.shared.enqueueDefaultErrorToast()
            }
        }
        
        self.registerView.tableView.deselectRow(focusedRow)
    }
    
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView) {
        guard let focusedRow = self.focusedRow else {
            return
        }
        
        self.registerView.tableView.deselectRow(focusedRow)
    }
    
}
