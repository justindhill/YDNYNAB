//
//  RegisterView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterView: NSView {

    let tableView = YDNTableView()
    let tableScrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented" )}
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.tableView.usesAlternatingRowBackgroundColors = true
        self.tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        self.tableScrollView.documentView = self.tableView
        self.addSubview(self.tableScrollView)
        
        self.tableScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.tableScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.tableScrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.tableScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.tableScrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
}
