//
//  PayeeSettingsSelectorViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

protocol PayeeSettingsSelectorViewControllerDelegate: AnyObject {
    func payeeSelector(_ selector: PayeeSettingsSelectorViewController, didSelectPayee: Int64?)
}

class PayeeSettingsSelectorViewController: NSViewController {
    
    enum Constant {
        static let columnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "YDNPayeeSettingsSelectorViewControllerColumn")
    }
    
    weak var delegate: PayeeSettingsSelectorViewControllerDelegate?
    
    let budgetContext: BudgetContext
    var payees: [Payee] = []
    let tableView = NSTableView()
    let scrollView = NSScrollView()
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetContext: BudgetContext) {
        self.budgetContext = budgetContext
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        self.view.addSubview(self.scrollView)
        self.scrollView.makeEdgesEqual(to: self.view)
        self.scrollView.documentView = self.tableView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.addTableColumn(withTitle: "Payees", identifier: Constant.columnIdentifier, resizingOptions: .autoresizingMask)
        
        if let payees = try? self.budgetContext.database.queue.read({ (db) -> [Payee] in return try Payee.fetchAll(db) }) {
            self.payees = payees
            self.tableView.reloadData()
        }  else {
            
        }
    }
    
}

extension PayeeSettingsSelectorViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.payees.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let payee = self.payees[row]
        
        let cell: YDNTableCellView
        if let existingCell = tableView.makeView(withIdentifier: Constant.columnIdentifier, owner: nil) as? YDNTableCellView {
            cell = existingCell
        } else {
            cell = YDNTableCellView()
            cell.identifier = Constant.columnIdentifier
        }
        
        cell.textField?.stringValue = payee.name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.delegate?.payeeSelector(self, didSelectPayee: self.payees[self.tableView.selectedRow].id)
    }
    
}
