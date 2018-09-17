//
//  RegisterViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController, NSTableViewDelegate {
    
    enum ColumnIdentifier: String {
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
        return RegisterRowView()
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
        var rows = IndexSet(integer: newSelectedRow)
        
        if let focusedRow = self.focusedRow {
            let rowView = self.registerView.tableView.rowView(atRow: focusedRow, makeIfNecessary: false) as? RegisterRowView
            rowView?.isEditing = false

            rows.insert(focusedRow)
        }
        
        let newSelectedRowView = self.registerView.tableView.rowView(atRow: newSelectedRow, makeIfNecessary: false) as? RegisterRowView
        newSelectedRowView?.isEditing = true
        
        self.focusedRow = self.registerView.tableView.selectedRow
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
    
}
