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
    func textFieldDidBlur(_ textField: YDNTextField, commit: Bool)
}

protocol YDNTextFieldKeyViewProvider: class {
    func nextKeyView(for textField: YDNTextField) -> YDNTextField?
    func previousKeyView(for textField: YDNTextField) -> YDNTextField?
}

class YDNTextField: NSTextField {
    
    /**
     Controls whether the text field is really editable. `isEditable` is the system-implemented flag, which YDNTextField
     modifies internally to accomplish certain tasks. Use this if you want the text field to be really un-editable.
     */
    var ydn_isEditable: Bool = false {
        didSet {
            if ydn_isEditable && !ydn_isEditable == oldValue && !self.isFocused {
                self.isEditable = false
                self.isSelectable = false
                self.addGestureRecognizer(self.clickRecognizer)
            } else if !ydn_isEditable {
                self.isEditable = false
                self.isSelectable = false
                self.removeGestureRecognizer(self.clickRecognizer)
            }
        }
    }
    
    weak var keyViewProvider: YDNTextFieldKeyViewProvider?
    weak var focusDelegate: YDNTextFieldDelegate?
    
    lazy private var clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(selectAllAndEdit))
    private var isFirstResponder: Bool = false
    private var isFocused: Bool = false
    
    required init?(coder: NSCoder) { fatalError() }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isEditable = false
        self.isSelectable = false
    }
    
    @objc func selectAllAndEdit() {
        if !self.ydn_isEditable || (self.isEditable && self.clickRecognizer.view == nil) {
            return
        }
        
        self.removeGestureRecognizer(self.clickRecognizer)
        self.isEditable = true
        self.isSelectable = true
        self.isFocused = true
        print("\(self.stringValue) focused")
        self.selectText(self)
    }

    override func becomeFirstResponder() -> Bool {
        print("\(self.stringValue) become first responder")

        let isFirstResponder = super.becomeFirstResponder()
        self.isFirstResponder = isFirstResponder

        return isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let resign = super.resignFirstResponder()

        if let editor = self.currentEditor() {
            self.isFocused = true
            self.focusDelegate?.textFieldDidFocus(self)
            print("\(self.stringValue) focused")
        } else {
            print("\(self.stringValue) about to be a goner")
        }

        return resign
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        print("\(self.stringValue) text ended editing")
        
        self.isSelectable = false
        self.isEditable = false
        self.addGestureRecognizer(self.clickRecognizer)

        var textMovement: NSTextMovement = .other
        if let textMovementRawValue = notification.userInfo?["NSTextMovement"] as? Int {
            textMovement = NSTextMovement(rawValue: textMovementRawValue) ?? .other
        }
        
        let commitMovements: [NSTextMovement] = [.return, .tab, .backtab]

        print("\(self.stringValue) no longer focused")
        self.isFocused = false
        self.focusDelegate?.textFieldDidBlur(self, commit: (commitMovements.contains(textMovement)))
        
        if let keyViewProvider = self.keyViewProvider {
            if textMovement == .tab {
                let next = keyViewProvider.nextKeyView(for: self)
                next?.selectAllAndEdit()
            } else if textMovement == .backtab {
                let previous = keyViewProvider.previousKeyView(for: self)
                previous?.selectAllAndEdit()
            }
        }
    }
    
    override func textShouldEndEditing(_ textObject: NSText) -> Bool {
        print("should it end?")
        return super.textShouldEndEditing(textObject)
    }
    
    override func doCommand(by selector: Selector) {
        if selector == #selector(cancelOperation(_:)) {
            print("\(self.stringValue) no longer focused 1")
            self.isFocused = false
            self.focusDelegate?.textFieldDidBlur(self, commit: false)
        }
                
        super.doCommand(by: selector)
    }
    
}
