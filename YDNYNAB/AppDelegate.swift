//
//  AppDelegate.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var appContext: AppContext!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.appContext = AppContext()
        self.window = NSWindow(contentRect: self.calculateInitialWindowFrame(),
                               styleMask: [.closable, .miniaturizable, .resizable, .titled],
                               backing: .buffered,
                               defer: false)
        self.window.title = "YDNYNAB"
        self.window.contentViewController = MainSplitViewController(appContext: self.appContext)
        self.window.setFrame(self.calculateInitialWindowFrame(), display: true)
        self.window.makeKeyAndOrderFront(self)        
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
