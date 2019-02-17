//
//  PayeeSettingsViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class PayeeSettingsViewController: NSSplitViewController {
    
    let selectorViewController: PayeeSettingsSelectorViewController
    let budgetContext: BudgetContext
    lazy var selectorSplitItem = NSSplitViewItem(contentListWithViewController: self.selectorViewController)
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetContext: BudgetContext) {
        self.budgetContext = budgetContext
        self.selectorViewController = PayeeSettingsSelectorViewController(budgetContext: budgetContext)
        super.init(nibName: nil, bundle: nil)
        
        self.selectorViewController.delegate = self
    }
    
    override func loadView() {
        self.splitView = NSSplitView()
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        self.splitView.isVertical = true
        self.splitView.dividerStyle = .thin
        self.view.addSubview(self.splitView)
        self.splitView.makeEdgesEqual(to: self.view)
        
        let contentItem = self.editorSplitViewItem(forPayeeId: 0)
        self.splitViewItems = [self.selectorSplitItem, contentItem]
        self.preferredContentSize = NSSize(width: 800, height: 600)
    }
    
    override func keyDown(with event: NSEvent) {
        if let window = self.view.window {
            window.sheetParent?.endSheet(window)
        }
    }
    
    func editorSplitViewItem(forPayeeId id: Int64) -> NSSplitViewItem {
        let vc = PayeeSettingsEditorViewController(payeeId: id, budgetContext: self.budgetContext)
        let item = NSSplitViewItem(viewController: vc)
        return item
    }

}

extension PayeeSettingsViewController: PayeeSettingsSelectorViewControllerDelegate {
    
    func payeeSelector(_ selector: PayeeSettingsSelectorViewController, didSelectPayee payeeId: Int64?) {
        if let payeeId = payeeId {
            self.splitViewItems[1] = self.editorSplitViewItem(forPayeeId: payeeId)
        }
    }
    
}
