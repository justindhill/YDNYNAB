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
    func textFieldDidBlur(_ textField: YDNTextField, commit: Bool, textMovement: NSTextMovement)
}

protocol YDNTextFieldKeyViewProvider: AnyObject {
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

    var forwardMovements: [NSTextMovement] = [.tab, .return]
    var committingMovements: [NSTextMovement] = [.tab, .backtab, .return]
    var backwardMovements: [NSTextMovement] = [.backtab]
    
    weak var keyViewProvider: YDNTextFieldKeyViewProvider?
    weak var focusDelegate: YDNTextFieldDelegate?
    
    lazy private var clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(selectAllAndEdit))
    private var isFirstResponder: Bool = false
    
    var initialFocusedValue: String?
    private(set) var isFocused: Bool = false {
        didSet {
            if isFocused != oldValue {
                if isFocused {
                    self.removeGestureRecognizer(self.clickRecognizer)
                    self.isEditable = true
                    self.isSelectable = true
                } else {
                    self.isSelectable = false
                    self.isEditable = false
                    self.addGestureRecognizer(self.clickRecognizer)
                }
                
                self.initialFocusedValue = isFocused ? self.stringValue : nil
            }
        }
    }
    
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
        
        self.isFocused = true
        self.selectText(self)
    }

    override func becomeFirstResponder() -> Bool {
        let isFirstResponder = super.becomeFirstResponder()
        self.isFirstResponder = isFirstResponder

        return isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let resign = super.resignFirstResponder()

        if self.currentEditor() != nil {
            self.isFocused = true
            self.focusDelegate?.textFieldDidFocus(self)
        }

        return resign
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)

        var textMovement: NSTextMovement = .other
        if let textMovementRawValue = notification.userInfo?["NSTextMovement"] as? Int {
            textMovement = NSTextMovement(rawValue: textMovementRawValue) ?? .other
        }
        
        if !self.committingMovements.contains(textMovement) {
            self.stringValue = self.initialFocusedValue ?? ""
        }
        self.isFocused = false
        self.focusDelegate?.textFieldDidBlur(self, commit: (self.committingMovements.contains(textMovement)), textMovement: textMovement)
        
        if let keyViewProvider = self.keyViewProvider {
            if self.forwardMovements.contains(textMovement) {
                let next = keyViewProvider.nextKeyView(for: self)
                next?.selectAllAndEdit()
            } else if self.backwardMovements.contains(textMovement) {
                let previous = keyViewProvider.previousKeyView(for: self)
                previous?.selectAllAndEdit()
            }
        }
    }
    
    override func doCommand(by selector: Selector) {
        if selector == #selector(cancelOperation(_:)) {
            self.isFocused = false
            self.focusDelegate?.textFieldDidBlur(self, commit: false, textMovement: .other)
        }
                
        super.doCommand(by: selector)
    }
    
}
