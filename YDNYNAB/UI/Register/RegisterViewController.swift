//
//  RegisterViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterViewController: NSViewController, NSOutlineViewDelegate, RegisterCellDelegate, RegisterEditControllerDelegate {
    
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
    var editController: RegisterEditController? {
        didSet {
            if oldValue == editController {
                return
            }
            
            oldValue?.endEditing()
            editController?.delegate = self
            editController?.beginEditing()
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
        guard let transaction = item as? Transaction else {
            fatalError("RegisterViewController only displays transactions")
        }
        
        let rowView: RegisterRowView
        if let existingRowView = outlineView.makeView(withIdentifier: Constant.rowViewIdentifier, owner: self) as? RegisterRowView {
            rowView = existingRowView
        } else {
            let newRowView = RegisterRowView()
            newRowView.identifier = Constant.rowViewIdentifier
            rowView = newRowView
        }
        
        rowView.rowType = (transaction.splitParent == nil) ? .transaction : .splitChild
        return rowView
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
            view.columnIdentifier = columnIdentifier
            
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
        
        let controlRowTransaction = self.editController?.splitChildren.last ?? self.editController?.transaction
        if transaction == controlRowTransaction {
            return RegisterRowView.Constant.expandedHeight
        } else {
            return RegisterRowView.Constant.collapsedHeight
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        if let transaction = item as? Transaction, let editController = self.editController {
            return transaction != editController.transaction
        }
        
        return true
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        self.updateRowExpansionState(notification: notification, isExpanded: true)
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        self.updateRowExpansionState(notification: notification, isExpanded: false)
    }
    
    private var previousProposedFirstRow: Int = -1
    func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        guard self.editController == nil else {
            return self.outlineView.selectedRowIndexes
        }
        
        guard
            let firstSelectionIndex = proposedSelectionIndexes.first,
            let item = outlineView.item(atRow: firstSelectionIndex) else {
                return proposedSelectionIndexes
        }
        
        let updatedSelection = self.outlineView.rows(forItem: item)
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
    
    // MARK: - Actions
    @objc func outlineViewClicked() {
        let clickedRow = self.outlineView.clickedRow
        let topLevelTransaction = self.outlineView.topLevelItem(forRow: clickedRow) as? Transaction
        
        if clickedRow == self.candidateEditRow {
            if clickedRow >= 0,
                let transaction = self.outlineView.topLevelItem(forRow: clickedRow) as? Transaction,
                let editController = try? RegisterEditController(dataSource: self.dataSource, outlineView: self.outlineView, transaction: transaction) {
                
                self.editController = editController
                self.candidateEditRow = nil
            }
        } else if topLevelTransaction != self.editController?.transaction {
            self.editController = nil
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
            
            if self.editController == nil,
                let transaction = self.outlineView.topLevelItem(forRow: selectedRow) as? Transaction,
                let editController = try? RegisterEditController(dataSource: self.dataSource, outlineView: self.outlineView, transaction: transaction) {
                
                self.editController = editController
            }
        case .escape:
            self.editController = nil
        }
    }
    
    // MARK: - RegisterCellDelegate
    func registerCellDidClickDisclosureIndicator(_ cell: RegisterCell) {
        let row = self.outlineView.row(for: cell)
        if let item = self.outlineView.item(atRow: row) {
            self.outlineView.toggleExpansion(forItem: item)
        }
    }
    
    // MARK: - RegisterEditControllerDelegate
    func registerEditControllerDidEndEditing(committedEdit: Bool) {
        if committedEdit {
            self.ignoreNextReturnKeyUp = true
        }
        
        self.editController = nil
    }
    
}
