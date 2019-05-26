//
//  RegisterViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController, NSOutlineViewDelegate, RegisterRowViewDelegate, RegisterCellDelegate {
    
    enum Constant {
        static let rowViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "rowViewIdentifier")
    }
    
    enum Mode {
        case popover
        case full
    }
    
    enum MovementType {
        case up
        case down
        case endcap
        
        init(previousFirstRow: Int, proposedFirstRow: Int) {
            if previousFirstRow < proposedFirstRow {
                self = .down
            } else if proposedFirstRow < previousFirstRow {
                self = .up
            } else {
                self = .endcap
            }
        }
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
    
    var outlineView: YDNOutlineView {
        return self.registerView.outlineView
    }
    
    lazy var dataSource: RegisterViewDataSource = RegisterViewDataSource(dbQueue: self.budgetContext.database.queue)
    
    var ignoreNextReturnKeyUp: Bool = false
    let budgetContext: BudgetContext
    let mode: Mode
    var candidateEditRow: Int? = nil
    var editingTransaction: Transaction? = nil {
        didSet {
            if oldValue == editingTransaction {
                return
            }
            
            if editingTransaction?.splitParent != nil {
                fatalError("Only top-level transactions can be considered as editing transactions")
            }
            
            if let oldValue = oldValue {
                let oldRows = self.rows(forItem: oldValue)
                
                if let lastOldRow = oldRows.last {
                    self.updateRowEditingState(forRow: lastOldRow, editing: false)
                }
                
                if self.outlineView.isItemExpanded(oldValue) {
                    self.outlineView.collapseItem(oldValue, collapseChildren: true)
                }
            }
            
            if let editingTransaction = editingTransaction {
                if !self.outlineView.isItemExpanded(editingTransaction) {
                    self.outlineView.expandItem(editingTransaction, expandChildren: true)
                }
                
                let newRows = self.rows(forItem: editingTransaction)
                
                if let lastNewRow = newRows.last {
                    self.updateRowEditingState(forRow: lastNewRow, editing: true)
                }
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(0)
                self.outlineView.noteHeightOfRows(withIndexesChanged: newRows)
                CATransaction.commit()
            }
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
        self.outlineView.showsDisclosureIndicator = false
        self.outlineView.delegate = self
        self.outlineView.dataSource = self.dataSource
        
        self.outlineView.target = self
        self.outlineView.action = #selector(outlineViewClicked)
        
        self.registerView.scrollView.hasVerticalScroller = true
    }
    
    func addColumnsToTableView() {
        let tableView = self.outlineView
        
        switch self.mode {
        case .full:
            tableView.addTableColumn(withTitle: "Account",
                                     identifier: ColumnIdentifier.account.userInterfaceIdentifier,
                                     initialWidth: 140)
            tableView.addTableColumn(withTitle: "Date",
                                     identifier: ColumnIdentifier.date.userInterfaceIdentifier,
                                     initialWidth: 100)
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
            view.delegate = self
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
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        guard let transaction = item as? Transaction else {
            fatalError("RegisterViewController only shows transactions.")
        }
        
        if let editingTransaction = editingTransaction,
            transaction.splitParent == editingTransaction.id &&
            outlineView.childIndex(forItem: transaction) == outlineView.numberOfChildren(ofItem: editingTransaction) - 1 {
            
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
    
    private var previousProposedFirstRow: Int = -1
    func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        guard
            let firstSelectionIndex = proposedSelectionIndexes.first,
            let item = outlineView.item(atRow: firstSelectionIndex) else {
                return proposedSelectionIndexes
        }
        
        let updatedSelection = self.rows(forItem: item)
        let movementType = MovementType(previousFirstRow: self.previousProposedFirstRow, proposedFirstRow: firstSelectionIndex)
        if movementType != .endcap {
            self.previousProposedFirstRow = firstSelectionIndex
        }
        
        
        if outlineView.selectedRowIndexes == updatedSelection {
            if let firstRowInSelection = updatedSelection.first, case .up = movementType, firstRowInSelection != 0 {
                let newProposedRow = max(firstRowInSelection - 1, 0)
                return self.outlineView(outlineView, selectionIndexesForProposedSelection: IndexSet(integer: newProposedRow))
            } else if let lastRowInSelection = updatedSelection.last, case .down = movementType, lastRowInSelection != outlineView.numberOfRows - 1 {
                let newProposedRow = min(lastRowInSelection + 1, outlineView.numberOfRows - 1)
                return self.outlineView(outlineView, selectionIndexesForProposedSelection: IndexSet(integer: newProposedRow))
            } else {
                return outlineView.selectedRowIndexes
            }
        } else if let firstRowInSelection = updatedSelection.first, movementType == .up {
            outlineView.scrollRowToVisible(firstRowInSelection)
        } else if let lastRowInSelection = updatedSelection.last, movementType == .down {
            outlineView.scrollRowToVisible(lastRowInSelection)
        }
        
        return updatedSelection
    }
    
    // MARK: - Utils
    func topLevelItem(forRow row: Int) -> Any? {
        guard let item = self.outlineView.item(atRow: row) else {
            return nil
        }
        
        return self.topLevelItem(forItem: item)
    }
    
    func topLevelItem(forItem item: Any) -> Any {
        if let parent = self.outlineView.parent(forItem: item) {
            return parent
        }
        
        return item
    }
    
    /**
     Rows in the outline view associated with the item. If the item is currently expanded, this includes the item's
     children. If it is collapsed, it does not. If the item is a child, the rows include its parent and its siblings.
     */
    func rows(forItem item: Any) -> IndexSet {
        let topLevelItem = self.topLevelItem(forItem: item)
        var rows = IndexSet(integer: outlineView.row(forItem: topLevelItem))
        let childCount = outlineView.numberOfChildren(ofItem: topLevelItem)
        
        if childCount > 0 && outlineView.isItemExpanded(topLevelItem) {
            for i in 0..<childCount {
                let childItem = outlineView.child(i, ofItem: topLevelItem)
                rows.insert(outlineView.row(forItem: childItem))
            }
        }
        
        return rows
    }
    
    func updateRowEditingState(forRow row: Int, editing: Bool) {
        let rowView = self.outlineView.rowView(atRow: row, makeIfNecessary: false) as? RegisterRowView
        rowView?.isEditing = editing
    }
    
    func updateRowExpansionState(notification: Notification, isExpanded: Bool) {
        guard
            let transaction = notification.userInfo?["NSObject"] as? Transaction,
            let rowView = self.outlineView.rowView(forItem: transaction, makeIfNecessary: false) as? RegisterRowView else {
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
        let row = self.outlineView.row(for: rowView)
        if row != -1 {
            do {
                try self.dataSource.updateTransaction(forRow: row, inTableView: self.outlineView, withRowView: rowView)
                self.outlineView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(0..<ColumnIdentifier.allCases.count))
            } catch {
                Toaster.shared.enqueueDefaultErrorToast()
            }
        }
        
        self.editingTransaction = nil
        self.ignoreNextReturnKeyUp = true
    }
    
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView) {
        self.editingTransaction = nil
    }
    
    @objc func outlineViewClicked() {
        let clickedRow = self.outlineView.clickedRow
        let topLevelTransaction = self.topLevelItem(forRow: clickedRow) as? Transaction
        
        if clickedRow == self.candidateEditRow {
            if clickedRow >= 0, let transaction = self.topLevelItem(forRow: clickedRow) as? Transaction {
                self.editingTransaction = transaction
                self.candidateEditRow = nil
            }
        } else if topLevelTransaction != self.editingTransaction {
            self.editingTransaction = nil
            self.candidateEditRow = clickedRow
        }
    }
    
    override func keyDown(with event: NSEvent) {
        // intentionally empty to prevent beeps
    }
    
    override func keyUp(with event: NSEvent) {
        let selectedRow = self.outlineView.selectedRow
        guard let keyCode = KeyCode(rawValue: event.keyCode), selectedRow != -1 else {
            return
        }
        
        switch keyCode {
        case .return:
            if self.ignoreNextReturnKeyUp {
                self.ignoreNextReturnKeyUp = false
                break
            }
            
            if self.editingTransaction == nil, let transaction = self.topLevelItem(forRow: selectedRow) as? Transaction {
                self.editingTransaction = transaction
            }
        case .escape:
            self.editingTransaction = nil
        }
    }
    
    // MARK: - RegisterCellDelegate
    func registerCellDidClickDisclosureIndicator(_ cell: RegisterCell) {
        let row = self.outlineView.row(for: cell)
        if let item = self.outlineView.item(atRow: row) {
            self.outlineView.toggleExpansion(forItem: item)
        }
    }
    
}
