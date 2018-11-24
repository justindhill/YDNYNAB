//
//  MonthBudgetCurrencyTableCellView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetCurrencyTableCellView: NSTableCellView {
    
    enum Constant {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier(rawValue: "MonthBudgetCurrencyTableCellView")
    }
    
    let editingTextField = NSTextField.init(labelWithString: "")
    var editable: Bool = false {
        didSet {
            self.editingTextField.isEditable = editable
            self.editingTextField.isSelectable = editable
        }
    }
    
    var mouseoverCursor: NSCursor? = nil
    var underlinesTextOnMouseover: Bool = false
    
    var font: NSFont = NSFont.systemFont(ofSize: 13) {
        didSet {
            self.editingTextField.font = font
        }
    }
    
    var text: String? {
        didSet {
            self.editingTextField.stringValue = text ?? ""
        }
    }
    
    var alignment: NSTextAlignment = .left {
        didSet {
            self.editingTextField.alignment = alignment
        }
    }
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.identifier = Constant.reuseIdentifier
        
        self.editingTextField.focusRingType = .none
        self.editingTextField.sizeToFit()
        self.addSubview(self.editingTextField)
    }
    
    override func layout() {
        super.layout()
        
        self.editingTextField.textColor = Theme.Color.text
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let newTextLayerFrame = NSRect(
            x: 0,
            y: ceil((self.frame.size.height - self.editingTextField.frame.size.height) / 2),
            width: self.frame.size.width,
            height: self.editingTextField.frame.size.height)
        self.editingTextField.frame = newTextLayerFrame.insetBy(dx: 3, dy: 0)
        CATransaction.commit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.editable = false
        self.underlinesTextOnMouseover = false
        self.mouseoverCursor = nil
        self.text = nil
    }

}

extension MonthBudgetCurrencyTableCellView: Hoverable {
    
    func enterHoverState() {
        self.mouseoverCursor?.set()
        
        if let text = self.text, self.underlinesTextOnMouseover {
            let para = NSMutableParagraphStyle()
            para.alignment = self.alignment
            self.editingTextField.attributedStringValue = NSAttributedString(
                string: text,
                attributes: [
                    .font: self.font,
                    .foregroundColor: Theme.Color.text,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: Theme.Color.text,
                    .paragraphStyle: para
                ]
            )
        }
    }
    
    func leaveHoverState() {
        NSCursor.arrow.set()
        
        if self.underlinesTextOnMouseover {
            self.editingTextField.stringValue = self.text ?? ""
        }
    }
}
