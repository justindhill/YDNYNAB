//
//  BudgetWindowController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/1/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetWindowController: NSWindowController {
    
    enum Constant {
        static let toolbarIdentifier = NSToolbar.Identifier("BudgetWindowToolbar")
        static let budgetItemIdentifier = NSToolbarItem.Identifier("BudgetItem")
    }
    
    let budgetContext: BudgetContext
    let tabViewController: NSTabViewController
    
    lazy var segmentedControl = NSSegmentedControl(labels: [""],
                                                   trackingMode: .selectOne,
                                                   target: self,
                                                   action: #selector(selectedSegmentDidChange(_:)))
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetWrapper: BudgetPackageWrapper) {
        self.budgetContext = BudgetContext(budgetWrapper: budgetWrapper)
        
        let window = NSWindow(contentRect: .zero,
                              styleMask: [.closable, .miniaturizable, .resizable, .titled],
                              backing: .buffered,
                              defer: false)
        
        let mainViewController = MainTabViewController(budgetContext: self.budgetContext)
        self.tabViewController = mainViewController

        super.init(window: window)
        
        let toolbar = NSToolbar(identifier: Constant.toolbarIdentifier)
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self
        
        window.title = budgetWrapper.fileUrl.lastPathComponent
        window.toolbar = toolbar
        window.toolbar?.delegate = mainViewController
        window.contentViewController = mainViewController
        
        mainViewController.delegate = self
        
        window.setFrame(self.calculateInitialWindowFrame(), display: true)
    }
    
    func showPayeeSettings() {
        let payeeSettings = PayeeSettingsViewController(budgetContext: self.budgetContext)
        let window = NSWindow(contentViewController: payeeSettings)
        self.window?.beginSheet(window, completionHandler: nil)
    }
    
    func calculateInitialWindowFrame() -> CGRect {
        guard let screen = NSScreen.main else {
            return .zero
        }
        
        let initialWindowWidth: CGFloat = 1200
        let initialWindowHeight: CGFloat = 700
        let initialWindowX = (screen.frame.size.width - initialWindowWidth) / 2
        let initialWindowY = (screen.frame.size.height - initialWindowHeight) / 2
        let initialWindowFrame = NSRect(
            x: initialWindowX,
            y: initialWindowY,
            width: initialWindowWidth, height: initialWindowHeight)
        
        return initialWindowFrame
    }
    
    func updateSegmentedControl() {
        self.segmentedControl.segmentCount = self.tabViewController.tabViewItems.count
        self.tabViewController.tabViewItems.enumerated().forEach { (offset, item) in
            self.segmentedControl.setLabel(item.viewController?.title ?? "", forSegment: offset)
        }
        self.segmentedControl.selectedSegment = self.tabViewController.selectedTabViewItemIndex
    }
    
    @objc func selectedSegmentDidChange(_ sender: NSSegmentedControl) {
        self.tabViewController.selectedTabViewItemIndex = sender.selectedSegment
    }

}

extension BudgetWindowController: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        let item = NSToolbarItem(itemIdentifier: Constant.budgetItemIdentifier)
        item.view = self.segmentedControl
        return item
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [ .flexibleSpace, Constant.budgetItemIdentifier, .flexibleSpace]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [ Constant.budgetItemIdentifier, .flexibleSpace ]
    }
    
}

extension BudgetWindowController: MainTabViewControllerDelegate {
    
    func mainTabViewControllerItemsDidChange(_ tabViewController: NSTabViewController) {
        self.updateSegmentedControl()
    }
    
}
