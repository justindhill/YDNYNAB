//
//  BudgetOverviewView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import AppKit

class BudgetOverviewView: NSView {
    
    enum Constant {
        static let initialCategoryListWidth: CGFloat = 175
        static let padding: CGFloat = 10
        static let directionButtonHeight: CGFloat = 30
    }
    
    var separator = DraggableSeparatorView()
    
    let categoryListView: NSView
    
    let backButton = NSButton(title: "Back", target: nil, action: nil)
    let forwardButton = NSButton(title: "Forward", target: nil, action: nil)
    

    var budgetMonthSheetViews: [NSView]
    var budgetSheetWidthConstraints = [NSLayoutConstraint]()
        
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(budgetMonthSheetViews: [NSView], categoryListView: NSView) {
        self.budgetMonthSheetViews = budgetMonthSheetViews
        self.categoryListView = categoryListView
        
        super.init(frame: .zero)
        
        self.addSubview(self.categoryListView)
        categoryListView.make([.top, .left, .bottom],
                              equalTo: self,
                              insetBy: .with(top: Constant.padding + Constant.directionButtonHeight,
                                             left: Constant.padding,
                                             bottom: Constant.padding))
        categoryListView.make(.width, equalTo: Constant.initialCategoryListWidth)
        
        self.addSubview(self.backButton)
        backButton.make(.top, equalTo: self, constant: Constant.padding)
        backButton.make(.left, equalTo: .right, of: categoryListView, constant: Constant.padding)
        backButton.make(.height, equalTo: Constant.directionButtonHeight)
        
        self.addSubview(self.forwardButton)
        forwardButton.make(.top, equalTo: self, constant: Constant.padding)
        forwardButton.make(.left, equalTo: .right, of: backButton, constant: Constant.padding)
        forwardButton.make(.height, equalTo: Constant.directionButtonHeight)
        
        var lastSheet: NSView = self.categoryListView
        self.budgetMonthSheetViews.forEach({ budgetMonthSheetView in
            self.addSubview(budgetMonthSheetView)
            
            budgetMonthSheetView.translatesAutoresizingMaskIntoConstraints = false
            if budgetMonthSheetView != budgetMonthSheetViews.first {
                budgetMonthSheetView.make(.width, equalTo: lastSheet)
            }
            
            budgetMonthSheetView.make(.top, equalTo: self, constant: (2 * Constant.padding) + Constant.directionButtonHeight)
            budgetMonthSheetView.make(.left, equalTo: .right, of: lastSheet, constant: Constant.padding)
            budgetMonthSheetView.make(.bottom, equalTo: self, constant: -Constant.padding)

            if budgetMonthSheetView == budgetMonthSheetViews.last {
                budgetMonthSheetView.make(.right, equalTo: self, constant: -Constant.padding)
            }
            
            lastSheet = budgetMonthSheetView
        })
    }
    
    

}
