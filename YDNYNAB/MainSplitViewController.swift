//
//  MainSplitViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController, SidebarViewControllerDelegate {
    
    let sidebarViewController = SidebarViewController()
    let contentViewController = BudgetOverviewViewController()
    lazy var allTransactionsRegister = RegisterViewController()
    lazy var sidebarItem = NSSplitViewItem(sidebarWithViewController: self.sidebarViewController)

    
    override func loadView() {
        self.splitView = NSSplitView()
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitView.isVertical = true
        self.splitView.dividerStyle = .thin
        
        self.view.addSubview(self.splitView)
        self.splitView.translatesAutoresizingMaskIntoConstraints = false
        self.splitView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        self.splitView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.splitView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.splitView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        self.view.wantsLayer = true
        
        self.sidebarViewController.delegate = self
        self.sidebarViewController.view.wantsLayer = true
        self.contentViewController.view.wantsLayer = true
        
        sidebarItem.minimumThickness = 250
        sidebarItem.maximumThickness = 250
        sidebarItem.canCollapse = false
        let contentItem = NSSplitViewItem(viewController: self.contentViewController)
        
        self.splitViewItems = [sidebarItem, contentItem]
    }
    
    func sidebarViewController(_ sidebarViewController: SidebarViewController, selectionDidChange selection: SidebarViewController.SelectionIdentifier) {
        let contentItem: NSSplitViewItem

        switch selection {
        case .budget:
            contentItem = NSSplitViewItem(viewController: self.contentViewController)
        case .allTransactions:
            contentItem = NSSplitViewItem(viewController: self.allTransactionsRegister)
        }
        
        self.splitViewItems = [self.sidebarItem, contentItem]
    }
    
}
