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
    
    var itemBlocks = [NSMenuItem: () -> Void]()
    var rootMenu = NSMenu(title: "Blach")
    
    func populate() {
        NSApplication.shared.mainMenu = self.rootMenu
        self.populateMainMenu()
        self.populateFileMenu()
    }
    
    private func populateMainMenu() {
        let mainMenu = self.addMenu(named: "YDNYNAB")
        self.addItem(named: "About YDNYNAB", to: mainMenu) {
            print("About YDNYNAB")
        }
        self.addSeparator(to: mainMenu)
        self.addItem(named: "Quit YDNYNAB", key: "q", keyModifier: [.command], to: mainMenu) {
            NSApplication.shared.terminate(self)
        }
    }
    
    private func populateFileMenu() {
        let fileMenu = self.addMenu(named: "File")
        self.addItem(named: "Create tables", to: fileMenu) {
            YDNDatabase.createTablesIfNeeded()
        }
        
        self.addItem(named: "Import YNAB Data", to: fileMenu) {
            let _ = YNABBudgetImporter(csvFileUrl: URL(fileURLWithPath: "/Users/justin/Desktop/budget.csv"))
            let _ = YNABTransactionImporter(csvFileUrl: URL(fileURLWithPath: "/Users/justin/Desktop/transactions.csv"))
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
    
    private func addMenu(named name: String) -> NSMenu {
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let newMenu = NSMenu(title: name)
        menuItem.submenu = newMenu
        self.rootMenu.addItem(menuItem)
        
        return newMenu
    }
    
    @objc private func dispatchSelection(_ menuItem: NSMenuItem) {
        self.itemBlocks[menuItem]?()
    }
    
}
