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
        currencyTextField.cell?.truncatesLastVisibleLine = true
        currencyTextField.cell?.lineBreakMode = .byTruncatingTail
        
        self.addSubview(self.currencyTextField)
        self.currencyTextField.snp.makeConstraints({ currencyTextField in
            currencyTextField.left.equalTo(self)
            currencyTextField.right.equalTo(self)
            currencyTextField.centerY.equalTo(self)
        })
    }

}
