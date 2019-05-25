//
//  RegisterViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController, NSOutlineViewDelegate, RegisterRowViewDelegate {
    
    enum Constant {
        static let rowViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "rowViewIdentifier")
    }
    
    enum Mode {
        case popover
        case full
    }
    
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
    
    lazy var dataSource: RegisterViewDataSource = RegisterViewDataSource(dbQueue: self.budgetContext.database.queue)
    
    var ignoreNextReturnKeyUp: Bool = false
    let budgetContext: BudgetContext
    let mode: Mode
    var candidateEditRow: Int? = nil
    var focusedRow: Int? = nil {
        didSet {
            var rowsWithChanges = IndexSet()
            
            if let oldValue = oldValue {
                let rowView = self.registerView.outlineView.rowView(atRow: oldValue, makeIfNecessary: false) as? RegisterRowView
                rowView?.isEditing = false
                rowsWithChanges.insert(oldValue)
            }
            
            if let focusedRow = self.focusedRow {
                let newSelectedRowView = self.registerView.outlineView.rowView(atRow: focusedRow, makeIfNecessary: false) as? RegisterRowView
                newSelectedRowView?.isEditing = true
                rowsWithChanges.insert(focusedRow)
            }
            
            self.registerView.outlineView.noteHeightOfRows(withIndexesChanged: rowsWithChanges)
        }
    }
    
    init(mode: Mode, budgetContext: BudgetContext) {
        self.budgetContext = budgetContext
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Accounts"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addColumnsToTableView()
        self.registerView.outlineView.showsDisclosureIndicator = false
        self.registerView.outlineView.delegate = self
        self.registerView.outlineView.dataSource = self.dataSource
        
        self.registerView.outlineView.target = self
        self.registerView.outlineView.action = #selector(outlineViewClicked)
        
        self.registerView.scrollView.hasVerticalScroller = true
    }
    
    func addColumnsToTableView() {
        let tableView = self.registerView.outlineView
        
        switch self.mode {
        case .full:
            tableView.addTableColumn(withTitle: "Account",
                                     identifier: ColumnIdentifier.account.userInterfaceIdentifier,
                                     initialWidth: 140)
            tableView.addTableColumn(withTitle: "Date",
                                     identifier: ColumnIdentifier.date.userInterfaceIdentifier,
                                     initialWidth: 80)
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
        case .popover:
            tableView.addTableColumn(withTitle: "Date",
                                     identifier: ColumnIdentifier.date.userInterfaceIdentifier,
                                     initialWidth: 70)
            tableView.addTableColumn(withTitle: "Account",
                                     identifier: ColumnIdentifier.account.userInterfaceIdentifier,
                                     resizingOptions: .autoresizingMask)
            tableView.addTableColumn(withTitle: "Payee",
                                     identifier: ColumnIdentifier.payee.userInterfaceIdentifier,
                                     resizingOptions: .autoresizingMask)
            tableView.addTableColumn(withTitle: "Memo",
                                     identifier: ColumnIdentifier.memo.userInterfaceIdentifier,
                                     resizingOptions: .autoresizingMask)
            tableView.addTableColumn(withTitle: "Outflow",
                                     identifier: ColumnIdentifier.outflow.userInterfaceIdentifier,
                                     resizingOptions: .autoresizingMask)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        if let rowView = outlineView.makeView(withIdentifier: Constant.rowViewIdentifier, owner: self) as? NSTableRowView {
            return rowView
        } else {
            let rowView = RegisterRowView()
            rowView.delegate = self
            rowView.identifier = Constant.rowViewIdentifier
            
            return rowView
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn = tableColumn, let transaction = item as? Transaction else {
            return nil
        }
        
        let view: RegisterCell
        if let reusedView = outlineView.makeView(withIdentifier: tableColumn.identifier, owner: self) {
            view = reusedView as! RegisterCell
        } else {
            view = RegisterCell()
            view.identifier = tableColumn.identifier
        }
        
        if let columnIdentifier = ColumnIdentifier(rawValue: tableColumn.identifier.rawValue) {
            view.text = self.dataSource.text(forColumn: columnIdentifier, transaction: transaction)
            view.alignment = self.textAlignment(forColumnIdentifier: columnIdentifier)
            
            if columnIdentifier == ColumnIdentifier.category && transaction.isSplitParent {
                view.expansionState = outlineView.isItemExpanded(item) ? .expanded : .collapsed
            } else {
                view.expansionState = .none
            }
        }
        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.focusedRow = nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        let row = outlineView.row(forItem: item)
        
        if row == self.focusedRow {
            return RegisterRowView.Constant.expandedHeight
        } else {
            return RegisterRowView.Constant.collapsedHeight
        }
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        self.updateRowExpansionState(notification: notification, isExpanded: true)
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        self.updateRowExpansionState(notification: notification, isExpanded: false)
    }
    
    func updateRowExpansionState(notification: Notification, isExpanded: Bool) {
        guard
            let transaction = notification.userInfo?["NSObject"] as? Transaction,
            let rowView = self.registerView.outlineView.rowView(forItem: transaction, makeIfNecessary: false) as? RegisterRowView else {
                return
        }
        
        rowView.isExpanded = isExpanded
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
        let row = self.registerView.outlineView.row(for: rowView)
        if row != -1 {
            do {
                try self.dataSource.updateTransaction(forRow: row, inTableView: self.registerView.outlineView, withRowView: rowView)
                self.registerView.outlineView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(0..<ColumnIdentifier.allCases.count))
            } catch {
                Toaster.shared.enqueueDefaultErrorToast()
            }
        }
        
        self.focusedRow = nil
        self.ignoreNextReturnKeyUp = true
    }
    
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView) {
        self.focusedRow = nil
    }
    
    @objc func outlineViewClicked() {
        let clickedRow = self.registerView.outlineView.clickedRow
        if clickedRow == self.candidateEditRow {
            if clickedRow >= 0 {
                self.focusedRow = self.registerView.outlineView.selectedRow
                self.candidateEditRow = nil
            }
        } else {
            self.candidateEditRow = clickedRow
        }
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    override func keyUp(with event: NSEvent) {        
        let selectedRow = self.registerView.outlineView.selectedRow
        guard let keyCode = KeyCode(rawValue: event.keyCode), selectedRow != -1 else {
            return
        }
        
        switch keyCode {
        case .return:
            if self.ignoreNextReturnKeyUp {
                self.ignoreNextReturnKeyUp = false
                break
            }
            
            if self.focusedRow == nil {
                self.focusedRow = selectedRow
            }
        case .escape:
            self.focusedRow = nil
        }
    }
    
}
