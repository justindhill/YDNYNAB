//
//  BudgetOverviewView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import SnapKit

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
    var budgetSheetWidthConstraints = [LayoutConstraint]()
        
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(budgetMonthSheetViews: [NSView], categoryListView: NSView) {
        self.budgetMonthSheetViews = budgetMonthSheetViews
        self.categoryListView = categoryListView
        
        super.init(frame: .zero)
        
        self.addSubview(self.categoryListView)
        self.categoryListView.snp.makeConstraints { (categoryListView) in
            categoryListView.top.equalTo(self).offset(Constant.padding + Constant.directionButtonHeight)
            categoryListView.left.equalTo(self).offset(Constant.padding)
            categoryListView.width.equalTo(Constant.initialCategoryListWidth)
            categoryListView.bottom.equalTo(self).offset(-Constant.padding)
        }
        
        self.addSubview(self.backButton)
        self.backButton.snp.makeConstraints { (backButton) in
            backButton.top.equalTo(self).offset(Constant.padding)
            backButton.left.equalTo(self.categoryListView.snp.right).offset(Constant.padding)
            backButton.height.equalTo(Constant.directionButtonHeight)
        }
        
        self.addSubview(self.forwardButton)
        self.forwardButton.snp.makeConstraints { (forwardButton) in
            forwardButton.top.equalTo(self).offset(Constant.padding)
            forwardButton.left.equalTo(self.backButton.snp.right).offset(Constant.padding)
            forwardButton.height.equalTo(Constant.directionButtonHeight)
        }
        
        var lastSheet: NSView = self.categoryListView
        self.budgetMonthSheetViews.forEach({ budgetMonthSheetView in
            self.addSubview(budgetMonthSheetView)
            
            budgetMonthSheetView.snp.makeConstraints({ (budgetMonthSheetMaker) in
                if budgetMonthSheetView != self.budgetMonthSheetViews.first {
                    budgetMonthSheetMaker.width.equalTo(lastSheet)
                }
                budgetMonthSheetMaker.top.equalTo(self).offset((2 * Constant.padding) + Constant.directionButtonHeight)
                budgetMonthSheetMaker.left.equalTo(lastSheet.snp.right).offset(Constant.padding)
                budgetMonthSheetMaker.bottom.equalTo(self).offset(-Constant.padding)
                
                if budgetMonthSheetView == self.budgetMonthSheetViews.last {
                    budgetMonthSheetMaker.right.equalTo(self).offset(-Constant.padding)
                }
            })
            
            lastSheet = budgetMonthSheetView
        })
    }
    
    

}
