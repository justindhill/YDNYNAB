//
//  asdf.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/2/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

extension NSTextView {
    class func createLabel() -> NSTextView {
        let textView = NSTextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        
        return textView
    }
}

extension NSTextField {
    class func createLabel() -> NSTextField {
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.isEditable = false
        
        return textField
    }
}
