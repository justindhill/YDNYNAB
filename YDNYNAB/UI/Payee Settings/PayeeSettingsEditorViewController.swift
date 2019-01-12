//
//  PayeeSettingsEditorViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class PayeeSettingsEditorViewController: NSViewController {
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    init(payeeId: Int64, budgetContext: BudgetContext) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
