//
//  YDNTextField.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/18/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol YDNTextFieldDelegate: NSTextFieldDelegate {
    func textFieldDidFocus(_ textField: YDNTextField)
    func textFieldDidBlur(_ textField: YDNTextField, dueTo movement: NSTextMovement)
}

class YDNTextField: NSTextField {
    
    var focusDelegate: YDNTextFieldDelegate?
    
    private var isFirstResponder: Bool = false
    private var isFocused: Bool = false
    
    override func becomeFirstResponder() -> Bool {
        print("\(self.stringValue) become first responder")

        let isFirstResponder = super.becomeFirstResponder()
        self.isFirstResponder = isFirstResponder
        
        return isFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        let resign = super.resignFirstResponder()
        
        if self.currentEditor() != nil {
            self.isFocused = true
            self.focusDelegate?.textFieldDidFocus(self)
            print("\(self.stringValue) focused")
        } else {
            print("\(self.stringValue) about to be a goner")
        }
        
        return resign
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        print("\(self.stringValue) text ended editing")
        
        if self.isFocused {
            var textMovement: NSTextMovement = .other
            if let textMovementRawValue = notification.userInfo?["NSTextMovement"] as? Int {
                textMovement = NSTextMovement(rawValue: textMovementRawValue) ?? .other
            }

            self.isFocused = false
            self.focusDelegate?.textFieldDidBlur(self, dueTo: textMovement)
        }
    }
    
}
