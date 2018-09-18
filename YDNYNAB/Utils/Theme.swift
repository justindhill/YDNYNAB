//
//  Theme.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/17/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

struct Theme {
    struct Color {
        static var text: NSColor { return Theme.isDarkMode ? .white : .black }
        static var rowBackgroundHoverColor: NSColor { return NSColor(white: Theme.isDarkMode ? 0.15 : 0.95, alpha: 1) }
    }
    
    private static var isDarkMode: Bool {
        if #available(macOS 10.14, *) {
            if NSApplication.shared.effectiveAppearance.name == .darkAqua {
                return true
            }
        }
        
        return false
    }
}
