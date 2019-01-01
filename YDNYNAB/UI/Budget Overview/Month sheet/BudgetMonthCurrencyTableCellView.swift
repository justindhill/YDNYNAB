//
//  BudgetMonthCurrencyTableCellView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol BudgetMonthCurrencyTableCellViewKeyViewProvider: class {
    func nextKeyView(for view: BudgetMonthCurrencyTableCellView) -> YDNTextField?
    func previousKeyView(for view: BudgetMonthCurrencyTableCellView) -> YDNTextField?
}

protocol BudgetMonthCurrencyTableCellViewDelegate: class {
    func budgetCurrencyCell(_ cell: BudgetMonthCurrencyTableCellView, didCommitValue value: Double?)
}

class BudgetMonthCurrencyTableCellView: NSTableCellView {
    
    enum Constant {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier(rawValue: "BudgetMonthCurrencyTableCellView")
    }
    
    var keyViewProvider: BudgetMonthCurrencyTableCellViewKeyViewProvider?
    weak var delegate: BudgetMonthCurrencyTableCellViewDelegate?
    
    lazy private var decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    let editingTextField = YDNTextField(labelWithString: "")
    var editable: Bool = false {
        didSet {
            self.editingTextField.ydn_isEditable = editable
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
        
        self.editingTextField.focusDelegate = self
        self.editingTextField.keyViewProvider = self
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

extension BudgetMonthCurrencyTableCellView: Hoverable {
    
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

extension BudgetMonthCurrencyTableCellView: YDNTextFieldDelegate {
    
    func textFieldDidFocus(_ textField: YDNTextField) {} // do nothing
    
    func textFieldDidBlur(_ textField: YDNTextField, commit: Bool) {
        if !commit {
            return
        }
        
        let nonNumeric = CharacterSet.decimalDigits.inverted
        let trimmedString = textField.stringValue.trimmingCharacters(in: nonNumeric)
        
        guard let parsedNumber = self.decimalNumberFormatter.number(from: trimmedString),
            let formattedString = self.decimalNumberFormatter.string(from: parsedNumber) else {
                textField.stringValue = ""
                self.delegate?.budgetCurrencyCell(self, didCommitValue: nil)
                return
        }
        
        textField.stringValue = formattedString
        self.delegate?.budgetCurrencyCell(self, didCommitValue: parsedNumber.doubleValue)
    }
    
}

extension BudgetMonthCurrencyTableCellView: YDNTextFieldKeyViewProvider {
    
    func nextKeyView(for textField: YDNTextField) -> YDNTextField? {
        return self.keyViewProvider?.nextKeyView(for: self)
    }
    
    func previousKeyView(for textField: YDNTextField) -> YDNTextField? {
        return self.keyViewProvider?.previousKeyView(for: self)
    }
    
}
