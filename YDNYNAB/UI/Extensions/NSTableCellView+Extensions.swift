//
//  NSTableCellView+Extensions.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

extension NSTableCellView {
    var rowView: NSTableRowView? {
        var node = self.superview
        while node != nil {
            if let node = node as? NSTableRowView {
                return node
            }
            
            node = node?.superview
        }
        
        return nil
    }
}
