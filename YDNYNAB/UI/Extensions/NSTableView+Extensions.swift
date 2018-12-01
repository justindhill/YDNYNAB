//
//  NSTableView+Extensions.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

extension NSTableView {
    func addTableColumn(withTitle title: String,
                        identifier: NSUserInterfaceItemIdentifier,
                        initialWidth: CGFloat? = nil,
                        resizingOptions: NSTableColumn.ResizingOptions? = .userResizingMask) {
        let column = NSTableColumn(identifier: identifier)
        column.title = title
        
        if let initialWidth = initialWidth {
            column.width = initialWidth
        }
        
        if let resizingOptions = resizingOptions {
            column.resizingMask = resizingOptions
        }
        
        self.addTableColumn(column)
    }
    
}
