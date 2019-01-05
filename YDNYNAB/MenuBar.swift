//
//  MenuBar.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MenuBar: NSObject {
    static let shared = MenuBar()
    
    var menus = [String: NSMenu]()
    var itemBlocks = [NSMenuItem: () -> Void]()
    var rootMenu = NSMenu(title: "")
    
    var currentKeyWindow: NSWindow?
    var currentBudgetWindowController: BudgetWindowController? {
        return self.currentKeyWindow?.windowController as? BudgetWindowController
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyWindowChanged(_:)),
                                               name: NSWindow.didBecomeKeyNotification,
                                               object: nil)
    }
    
    func populate() {
        NSApplication.shared.mainMenu = self.rootMenu
        self.populateMainMenu()
        self.populateFileMenu()
    }
    
    private func populateMainMenu() {
        let mainMenu = self.getOrAddMenu(named: "YDNYNAB")
        self.addItem(named: "About YDNYNAB", to: mainMenu) {
            print("About YDNYNAB")
        }
        
        self.addSeparator(to: mainMenu)
        self.addItem(named: "Quit YDNYNAB", key: "q", keyModifier: [.command], to: mainMenu) {
            NSApplication.shared.terminate(self)
        }
    }
    
    private func populateFileMenu() {
        let fileMenu = self.getOrAddMenu(named: "File")
        
        self.addItem(named: "Create new budget", key: "N", keyModifier: [.command, .shift], to: fileMenu) {
            let savePanel = NSSavePanel()
            savePanel.title = "New budget"
            savePanel.allowedFileTypes = ["ydnbudget"]
            savePanel.nameFieldStringValue = "My budget.ydnbudget"
            savePanel.isExtensionHidden = true
            savePanel.begin { response in
                if let url = savePanel.url, response == .OK {
                    let wrapper = FileWrapper(directoryWithFileWrappers: [:])
                    do {
                        if FileManager.default.fileExists(atPath: url.path) {
                            try FileManager.default.removeItem(at: url)
                        }
                        try wrapper.write(to: url, options: [], originalContentsURL: nil)
                        let _ = NSApplication.shared.delegate?.application?(NSApplication.shared, openFile: url.path)
                    } catch {
                        Toaster.shared.enqueueDefaultErrorToast()
                    }
                }
            }
        }
        
        self.addItem(named: "Open...", key: "o", keyModifier: [.command], to: fileMenu) {
            let openPanel = NSOpenPanel()
            openPanel.allowedFileTypes = ["ydnbudget"]
            openPanel.allowsMultipleSelection = false
            openPanel.begin { response in
                if let url = openPanel.url, response == .OK {
                    let _ = NSApplication.shared.delegate?.application?(NSApplication.shared, openFile: url.path)
                }
            }
        }
        
        self.addSeparator(to: fileMenu)
        
        self.addItem(named: "Migrate from YNAB", to: fileMenu) {
            guard let budgetContext = self.currentBudgetWindowController?.budgetContext else {
                Toaster.shared.enqueueDefaultErrorToast()
                return
            }
            
            let _ = YNABBudgetImporter(csvFileUrl: URL(fileURLWithPath: "/Users/justin/Desktop/budget.csv"), budgetContext: budgetContext)
            let _ = YNABTransactionImporter(csvFileUrl: URL(fileURLWithPath: "/Users/justin/Desktop/transactions.csv"), budgetContext: budgetContext)
        }
        
        self.addItem(named: "Import QFX/OFX", key: "i", keyModifier: [.command], to: fileMenu) {
            guard let budgetContext = self.currentBudgetWindowController?.budgetContext else {
                Toaster.shared.enqueueDefaultErrorToast()
                return
            }
            
            OFXImporter.import(budgetContext: budgetContext)
        }
    }
    
    private func addItem(named name: String, key: String = "", keyModifier: NSEvent.ModifierFlags = [], to menu: NSMenu, block: @escaping () -> Void) {
        let item = NSMenuItem(title: name, action: #selector(dispatchSelection(_:)), keyEquivalent: key)
        item.keyEquivalentModifierMask = keyModifier
        item.target = self
        self.itemBlocks[item] = block
        menu.addItem(item)
    }
    
    private func addSeparator(to menu: NSMenu) {
        menu.addItem(NSMenuItem.separator())
    }
    
    private func getOrAddMenu(named name: String) -> NSMenu {
        if let menu = self.menus[name] {
            return menu
        }
        
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let newMenu = NSMenu(title: name)
        menuItem.submenu = newMenu
        self.rootMenu.addItem(menuItem)
        self.menus[name] = newMenu
        
        return newMenu
    }
    
    @objc private func dispatchSelection(_ menuItem: NSMenuItem) {
        self.itemBlocks[menuItem]?()
    }
    
    @objc func keyWindowChanged(_ notification: Notification) {
        guard let newKeyWindow = notification.object as? NSWindow else {
            return
        }

        self.currentKeyWindow = newKeyWindow
    }
    
}
