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
    
    let categoryList = BudgetCategoriesViewController()
    
    let backButton = NSButton(title: "Back", target: nil, action: nil)
    let forwardButton = NSButton(title: "Forward", target: nil, action: nil)
    
    let monthBudgetSheets = [
        MonthBudgetSheetViewController(),
        MonthBudgetSheetViewController(),
        MonthBudgetSheetViewController()
    ]
    
    var budgetSheetWidthConstraints = [LayoutConstraint]()
        
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.categoryList.view)
        self.categoryList.view.snp.makeConstraints { (categoryListView) in
            categoryListView.top.equalTo(self).offset(Constant.padding + Constant.directionButtonHeight)
            categoryListView.left.equalTo(self).offset(Constant.padding)
            categoryListView.width.equalTo(Constant.initialCategoryListWidth)
            categoryListView.bottom.equalTo(self).offset(-Constant.padding)
        }
        
        self.addSubview(self.backButton)
        self.backButton.snp.makeConstraints { (backButton) in
            backButton.top.equalTo(self).offset(Constant.padding)
            backButton.left.equalTo(self.categoryList.view.snp.right).offset(Constant.padding)
            backButton.height.equalTo(Constant.directionButtonHeight)
        }
        
        self.addSubview(self.forwardButton)
        self.forwardButton.snp.makeConstraints { (forwardButton) in
            forwardButton.top.equalTo(self).offset(Constant.padding)
            forwardButton.left.equalTo(self.backButton.snp.right).offset(Constant.padding)
            forwardButton.height.equalTo(Constant.directionButtonHeight)
        }
        
        var lastSheet: NSViewController = self.categoryList
        self.monthBudgetSheets.forEach({ monthBudgetSheet in
            self.addSubview(monthBudgetSheet.view)
            
            monthBudgetSheet.view.snp.makeConstraints({ (monthBudgetSheetMaker) in
                if monthBudgetSheet != self.monthBudgetSheets.first {
                    monthBudgetSheetMaker.width.equalTo(lastSheet.view)
                }
                monthBudgetSheetMaker.top.equalTo(self).offset((2 * Constant.padding) + Constant.directionButtonHeight)
                monthBudgetSheetMaker.left.equalTo(lastSheet.view.snp.right).offset(Constant.padding)
                monthBudgetSheetMaker.bottom.equalTo(self).offset(-Constant.padding)
                
                if monthBudgetSheet == self.monthBudgetSheets.last {
                    monthBudgetSheetMaker.right.equalTo(self).offset(-Constant.padding)
                }
            })
            
            lastSheet = monthBudgetSheet
        })
    }
    
    

}
