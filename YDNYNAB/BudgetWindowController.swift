//
//  BudgetWindowController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/1/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetWindowController: NSWindowController {
    
    let budgetContext: BudgetContext
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetWrapper: BudgetPackageWrapper) {
        self.budgetContext = BudgetContext(budgetWrapper: budgetWrapper)
        
        let window = NSWindow(contentRect: .zero,
                              styleMask: [.closable, .miniaturizable, .resizable, .titled],
                              backing: .buffered,
                              defer: false)
        
        window.title = budgetWrapper.fileUrl.lastPathComponent
        window.contentViewController = MainSplitViewController(budgetContext: self.budgetContext)
        
        super.init(window: window)

        window.setFrame(self.calculateInitialWindowFrame(), display: true)
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

}
