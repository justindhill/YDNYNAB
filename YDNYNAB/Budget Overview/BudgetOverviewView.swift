//
//  BudgetOverviewView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetOverviewView: NSView {
    
    let monthBudgetSheets = [
        MonthBudgetSheetViewController(),
        MonthBudgetSheetViewController(),
        MonthBudgetSheetViewController()
    ]
        
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        var lastSheet: NSViewController?
        self.monthBudgetSheets.forEach({ monthBudgetSheet in
            self.addSubview(monthBudgetSheet.view)
            
            monthBudgetSheet.view.snp.makeConstraints({ (monthBudgetSheet) in
                monthBudgetSheet.top.equalTo(self)
                if let lastSheet = lastSheet {
                    monthBudgetSheet.left.equalTo(lastSheet.view.snp.right)
                } else {
                    monthBudgetSheet.left.equalTo(self)
                }
                monthBudgetSheet.width.equalTo(self).multipliedBy(CGFloat(1) / CGFloat(monthBudgetSheets.count))
                monthBudgetSheet.height.equalTo(self)
            })
            
            lastSheet = monthBudgetSheet
        })
    }

}
