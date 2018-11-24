//
//  BudgetCategoriesView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetCategoriesView: NSView {
    
    enum Constant {
        static let topOffset =
            BudgetMonthSheetView.Constant.summaryViewHeight +
            BudgetMonthSheetView.Constant.totalsViewHeight +
            BudgetOverviewView.Constant.padding
    }
    
    let outlineView = YDNOutlineView()
    let scrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.outlineView.floatsGroupRows = false
        
        self.scrollView.documentView = self.outlineView
        self.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (scrollView) in
            scrollView.top.equalTo(self).offset(Constant.topOffset)
            scrollView.left.equalTo(self)
            scrollView.right.equalTo(self)
            scrollView.bottom.equalTo(self)
        }
    }
}
