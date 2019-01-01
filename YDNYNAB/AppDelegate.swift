//
//  AppDelegate.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    enum Constant {
        static let lastBudgetOpenedKey = "YDNLastBudgetOpened"
    }

    var window: NSWindow!
    var budgetContext: BudgetContext!
    var windowControllers: [BudgetWindowController] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let lastBudget = UserDefaults.standard.string(forKey: Constant.lastBudgetOpenedKey),
            FileManager.default.fileExists(atPath: lastBudget) {
            self.openBudget(atPath: lastBudget)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        self.openBudget(atPath: filename)
        return true
    }
    
    func openBudget(atPath path: String) {
        for windowController in self.windowControllers {
            if windowController.budgetContext.budgetWrapper.fileUrl.path == path {
                windowController.showWindow(self)
                return
            }
        }
        
        do {
            let budgetWrapper = try BudgetPackageWrapper(path: path)
            self.budgetContext = BudgetContext(budgetWrapper: budgetWrapper)
            let windowController = BudgetWindowController(budgetWrapper: budgetWrapper)
            windowController.showWindow(self)
            self.windowControllers.append(windowController)
            
            UserDefaults.standard.set(path, forKey: Constant.lastBudgetOpenedKey)
        } catch {
            let alert = NSAlert(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't open the budget"]))
            alert.runModal()
        }
    }

}
