//
//  MainTabViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol MainTabViewControllerDelegate: AnyObject {
    func mainTabViewControllerItemsDidChange(_ tabViewController: NSTabViewController)
}

class MainTabViewController: NSTabViewController {
    
    enum Constant {
        static let toolbarIdentifier = NSToolbar.Identifier("BudgetWindowToolbar")
        static let budgetItemIdentifier = NSToolbarItem.Identifier("BudgetItem")
    }
    
    lazy var contentViewController = BudgetOverviewViewController(budgetContext: self.budgetContext)
    lazy var allTransactionsRegister = RegisterViewController(mode: .full, budgetContext: self.budgetContext)
    let budgetContext: BudgetContext
    var delegate: MainTabViewControllerDelegate?
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    init(budgetContext: BudgetContext) {
        self.budgetContext = budgetContext
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.tabView = NSTabView()
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tabView)
        self.tabView.makeEdgesEqual(to: self.view)
        
        self.view.wantsLayer = true
        self.tabView.tabPosition = .none
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.addChild(self.contentViewController)
        self.addChild(self.allTransactionsRegister)
        self.delegate?.mainTabViewControllerItemsDidChange(self)
    }
    
}
