//
//  YDNOutlineView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class YDNOutlineView: NSOutlineView {

    var showsDisclosureIndicator: Bool = true
    
    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        if self.showsDisclosureIndicator {
            return super.frameOfOutlineCell(atRow: row)
        } else {
            return .zero
        }
    }
    
}
