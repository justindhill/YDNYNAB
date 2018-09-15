//
//  BudgetOverviewViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetOverviewViewController: NSViewController, BudgetCategoriesViewControllerDelegate {
    
    override func loadView() {
        self.view = BudgetOverviewView()
    }
    
    var budgetOverviewView: BudgetOverviewView {
        return self.view as! BudgetOverviewView
    }
    
    var scrollViews = [NSScrollView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.budgetOverviewView.categoryList.delegate = self
        
        self.scrollViews.append(self.budgetOverviewView.categoryList.budgetCategoriesView.scrollView)
        self.scrollViews.append(contentsOf: self.budgetOverviewView.monthBudgetSheets.map { $0.budgetSheetView.detailsTableScrollView })
        self.scrollViews.forEach { scrollView in
            scrollView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(
                self, selector:
                #selector(scrollViewBoundsDidChange(_:)),
                name: NSView.boundsDidChangeNotification,
                object: scrollView.contentView)
        }
    }
    
    @objc func scrollViewBoundsDidChange(_ note: Notification) {
        guard let contentView = note.object as? NSClipView else {
            return
        }
        
        self.scrollViews.forEach { candidate in
            if candidate.contentView != contentView {
                candidate.contentView.scroll(to: contentView.bounds.origin)
                candidate.reflectScrolledClipView(candidate.contentView)
            }
        }
    }
    
    func budgetCategoriesViewController(_ viewController: BudgetCategoriesViewController, willExpandRow row: Int) {
        self.budgetOverviewView.monthBudgetSheets.forEach({ $0.expand(row: row) })
    }
    
    func budgetCategoriesViewController(_ viewController: BudgetCategoriesViewController, willCollapseRow row: Int) {
        self.budgetOverviewView.monthBudgetSheets.forEach({ $0.collapse(row: row) })
    }
    
}
