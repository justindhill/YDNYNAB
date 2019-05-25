//
//  RegisterView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterView: NSView {

    let outlineView = YDNOutlineView()
    let scrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented" )}
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.outlineView.selectsChildrenOfSelectedExpandedParent = true
        self.outlineView.usesAlternatingRowBackgroundColors = true
        self.outlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        self.scrollView.documentView = self.outlineView
        self.addSubview(self.scrollView)
        
        self.scrollView.make([.top, .left, .bottom, .right], equalTo: self)
    }
    
}
