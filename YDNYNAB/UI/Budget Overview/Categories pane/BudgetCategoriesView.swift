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
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.topOffset).isActive = true
        self.scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
}
