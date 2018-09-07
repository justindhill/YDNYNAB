//
//  MainSplitViewControllerView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MainSplitViewControllerView: NSView {

    let splitView = NSSplitView()
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    override func layout() {
        super.layout()
        
        if self.splitView.superview == nil {
            self.addSubview(self.splitView)
        }
        
        splitView.frame = self.bounds
    }
    
}
