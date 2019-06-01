//
//  RegisterEditController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 5/26/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

protocol RegisterEditControllerDelegate: class {
    func registerEditControllerDidEndEditing(committedEdit: Bool)
}

class RegisterEditController: NSObject, RegisterRowViewDelegate {
    
    fileprivate typealias ColumnIdentifier = RegisterViewController.ColumnIdentifier
    
    enum RegisterEditControllerError: Error {
        case invalidTransaction
    }
    
    let dataSource: RegisterViewDataSource
    let outlineView: YDNOutlineView
    let transaction: Transaction
    weak var initialCell: RegisterCell?
    private(set) var splitChildren: [Transaction]
    private var collapseTransactionOnEndEditing: Bool = false
    
    weak var delegate: RegisterEditControllerDelegate?
    
    init(dataSource: RegisterViewDataSource,
         outlineView: YDNOutlineView,
         transaction: Transaction,
         initialCell: RegisterCell? = nil) throws {
        
        self.dataSource = dataSource
        self.outlineView = outlineView
        self.transaction = transaction
        self.initialCell = initialCell
        
        guard let transactionId = transaction.id, transaction.splitParent == nil else {
            throw RegisterEditControllerError.invalidTransaction
        }
        
        self.splitChildren = dataSource.splitChildren[transactionId] ?? []
        super.init()
    }
    
    func beginEditing() {
        let itemCurrentlyExpanded = self.outlineView.isItemExpanded(self.transaction)
        self.collapseTransactionOnEndEditing = !itemCurrentlyExpanded
        if !itemCurrentlyExpanded {
            self.outlineView.expandItem(self.transaction, expandChildren: true)
        }

        let newRows = self.outlineView.rows(forItem: self.transaction)
        let newRowViews = newRows.map({ self.outlineView.rowView(atRow: $0, makeIfNecessary: false) as? RegisterRowView })
        newRowViews.forEach({ $0?.delegate = self })
        
        self.updateRowEditingState(forRows: newRows, editing: true)

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        self.outlineView.noteHeightOfRows(withIndexesChanged: newRows)
        CATransaction.commit()
        
        if let initialCell = self.initialCell {
            initialCell.inputTextField.selectAllAndEdit()
        } else if let firstRowView = newRowViews.first, let firstRowViewDoubleUnwrap = firstRowView {
            firstRowViewDoubleUnwrap.firstKeyView()?.selectAllAndEdit()
        }
    }
    
    func endEditing() {
        let transactionRows = self.outlineView.rows(forItem: self.transaction)
        self.updateRowEditingState(forRows: transactionRows, editing: false)
        
        if self.collapseTransactionOnEndEditing {
            self.outlineView.collapseItem(self.transaction, collapseChildren: true)
            
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        
        self.outlineView.noteHeightOfRows(withIndexesChanged: transactionRows)
        
        CATransaction.commit()
        
        self.outlineView.window?.makeFirstResponder(self.outlineView)
    }
    
    func updateRowEditingState(forRows rows: IndexSet, editing: Bool) {
        rows.forEach { row in
            let rowView = self.outlineView.rowView(atRow: row, makeIfNecessary: false) as? RegisterRowView
            rowView?.isEditing = editing
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
        
        self.delegate?.registerEditControllerDidEndEditing(committedEdit: true)
    }
    
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView) {
        self.delegate?.registerEditControllerDidEndEditing(committedEdit: false)
    }
    
    func registerRowViewNextRowView(_ rowView: RegisterRowView) -> RegisterRowView? {
        return self.rowView(forRowView: rowView) {$0 + 1}
    }
    
    func registerRowViewPreviousRowView(_ rowView: RegisterRowView) -> RegisterRowView? {
        return self.rowView(forRowView: rowView) {$0 - 1}
    }
    
    func rowView(forRowView rowView: RegisterRowView, indexTransform: (Int) -> Int) -> RegisterRowView? {
        let editingRows = self.outlineView.rows(forItem: self.transaction)
        let row = self.outlineView.row(for: rowView)
        let candidateRow = indexTransform(row)
        
        if row != -1 && editingRows.contains(candidateRow),
            let candidateRowView = self.outlineView.rowView(atRow: candidateRow, makeIfNecessary: false) as? RegisterRowView {
            return candidateRowView
        }
        
        return nil
    }

}
