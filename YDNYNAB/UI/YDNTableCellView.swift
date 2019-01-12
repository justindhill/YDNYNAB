//
//  YDNTableCellView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class YDNTableCellView: NSTableCellView {
    
    private let internalTextField = NSTextField(labelWithString: "")
    
    required init?(coder decoder: NSCoder) { fatalError("not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.textField = self.internalTextField
        self.addSubview(self.internalTextField)
        self.internalTextField.makeEdgesEqual(to: self)
    }

}
