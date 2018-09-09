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
    }
    
    var separator = DraggableSeparatorView()
    
    let categoryList = BudgetCategoriesViewController()
    
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
            categoryListView.top.equalTo(self)
            categoryListView.left.equalTo(self).offset(Constant.padding)
            categoryListView.width.equalTo(Constant.initialCategoryListWidth)
            categoryListView.bottom.equalTo(self).offset(-Constant.padding)
        }
        
        var lastSheet: NSViewController = self.categoryList
        self.monthBudgetSheets.forEach({ monthBudgetSheet in
            self.addSubview(monthBudgetSheet.view)
            
            monthBudgetSheet.view.snp.makeConstraints({ (monthBudgetSheetMaker) in
                if monthBudgetSheet != self.monthBudgetSheets.first {
                    monthBudgetSheetMaker.width.equalTo(lastSheet.view)
                }
                monthBudgetSheetMaker.top.equalTo(self).offset(Constant.padding)
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
