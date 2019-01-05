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
        categoryListView.translatesAutoresizingMaskIntoConstraints = false
        categoryListView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.padding + Constant.directionButtonHeight).isActive = true
        categoryListView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constant.padding).isActive = true
        categoryListView.widthAnchor.constraint(equalToConstant: Constant.initialCategoryListWidth).isActive = true
        categoryListView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constant.padding).isActive = true
        
        self.addSubview(self.backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.padding).isActive = true
        backButton.leftAnchor.constraint(equalTo: categoryListView.rightAnchor, constant: Constant.padding).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: Constant.directionButtonHeight).isActive = true
        
        self.addSubview(self.forwardButton)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.padding).isActive = true
        forwardButton.leftAnchor.constraint(equalTo: backButton.rightAnchor, constant: Constant.padding).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: Constant.directionButtonHeight).isActive = true
        
        var lastSheet: NSView = self.categoryListView
        self.budgetMonthSheetViews.forEach({ budgetMonthSheetView in
            self.addSubview(budgetMonthSheetView)
            
            budgetMonthSheetView.translatesAutoresizingMaskIntoConstraints = false
            if budgetMonthSheetView != budgetMonthSheetViews.first {
                budgetMonthSheetView.widthAnchor.constraint(equalTo: lastSheet.widthAnchor).isActive = true
            }
            
            budgetMonthSheetView.topAnchor.constraint(equalTo: self.topAnchor,
                                                      constant: (2 * Constant.padding) + Constant.directionButtonHeight).isActive = true
            budgetMonthSheetView.leftAnchor.constraint(equalTo: lastSheet.rightAnchor, constant: Constant.padding).isActive = true
            budgetMonthSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constant.padding).isActive = true

            if budgetMonthSheetView == budgetMonthSheetViews.last {
                budgetMonthSheetView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Constant.padding).isActive = true
            }
            
            lastSheet = budgetMonthSheetView
        })
    }
    
    

}
