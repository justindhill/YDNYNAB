//
//  MonthBudgetCurrencyTableCellView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetCurrencyTableCellView: NSTableCellView {
    
    let currencyTextField = NSTextField(labelWithString: "")
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.currencyTextField.alignment = .right
        self.addSubview(self.currencyTextField)
    }
    
    override func layout() {
        super.layout()
        self.currencyTextField.frame = self.bounds
    }

}
