//
//  RegisterView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterView: NSView {

    let tableView = NSTableView()
    let tableScrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented" )}
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.tableView.usesAlternatingRowBackgroundColors = true
        self.tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        self.tableScrollView.documentView = self.tableView
        self.addSubview(self.tableScrollView)
        self.tableScrollView.snp.makeConstraints { tableScrollView in
            tableScrollView.edges.equalTo(self)
        }
    }
    
}
