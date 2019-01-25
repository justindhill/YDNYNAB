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
    
    struct Font {
        static var f0: NSFont = { appFont(ofSize: 10) }()
        static var f1: NSFont = { appFont(ofSize: 12) }()
        static var f2: NSFont = { appFont(ofSize: 14) }()
        static var f3: NSFont = { appFont(ofSize: 16) }()
        static var f4: NSFont = { appFont(ofSize: 18) }()
        
        private static func appFont(ofSize size: CGFloat) -> NSFont {
            return NSFont.systemFont(ofSize: size)
        }
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
