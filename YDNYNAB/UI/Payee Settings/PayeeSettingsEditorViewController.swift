//
//  PayeeSettingsEditorViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class PayeeSettingsEditorViewController: NSViewController {
    
    enum Constant {
        static let padding: CGFloat = 10
    }
    
    let payeeId: Int64
    let nameLabel = YDNTextField()
    let budgetContext: BudgetContext
    var payee: Payee?
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    init(payeeId: Int64, budgetContext: BudgetContext) {
        self.budgetContext = budgetContext
        self.payeeId = payeeId
        
        super.init(nibName: nil, bundle: nil)
        
        self.nameLabel.ydn_isEditable = true
        self.nameLabel.focusDelegate = self
        
        self.view.addSubview(self.nameLabel)
        self.nameLabel.make([.left, .top, .right], equalTo: self.view, insetBy: .equal(Constant.padding))
    }
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.nameLabel.font = Theme.Font.f4

        self.reloadData()
    }
    
    func reloadData() {
        do {
            guard let payee = try self.budgetContext.database.queue.read({ return try Payee.fetchOne($0, key: self.payeeId) }) else {
                self.showErrorState()
                return
            }
            
            self.payee = payee
            self.nameLabel.stringValue = payee.name
            
        } catch {
            self.showErrorState()
        }
    }
    
    func showErrorState() {
        
    }
    
}

extension PayeeSettingsEditorViewController: YDNTextFieldDelegate {
    
    func textFieldDidFocus(_ textField: YDNTextField) {
        
    }
    
    func textFieldDidBlur(_ textField: YDNTextField, commit: Bool) {
        guard let payee = self.payee, commit else {
            return
        }
        
        if textField === self.nameLabel {
            payee.name = textField.stringValue
        }
        
        do {
            try self.budgetContext.database.queue.write { (db) -> Void in
                try payee.save(db)
            }
        } catch {
            Toaster.shared.enqueueDefaultErrorToast()
        }
    }
    
}
