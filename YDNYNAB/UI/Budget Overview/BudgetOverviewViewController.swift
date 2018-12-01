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
        self.view = BudgetOverviewView(budgetMonthSheetViews: self.budgetMonthSheets.map { $0.view })
    }
    
    var budgetOverviewView: BudgetOverviewView {
        return self.view as! BudgetOverviewView
    }
    
    var scrollViews = [NSScrollView]()
    
    var offsetFromCurrentMonth: Int = 0
    
    lazy var budgetMonthSheets = [
        BudgetMonthSheetViewController(appContext: self.appContext),
        BudgetMonthSheetViewController(appContext: self.appContext),
        BudgetMonthSheetViewController(appContext: self.appContext)
    ]
    
    let appContext: AppContext
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    init(appContext: AppContext) {
        self.appContext = appContext
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.budgetOverviewView.categoryList.delegate = self
        self.budgetOverviewView.backButton.target = self
        self.budgetOverviewView.backButton.action = #selector(backButtonClicked)
        self.budgetOverviewView.forwardButton.target = self
        self.budgetOverviewView.forwardButton.action = #selector(forwardButtonClicked)
        
        self.scrollViews.append(self.budgetOverviewView.categoryList.budgetCategoriesView.scrollView)
        self.scrollViews.append(contentsOf: self.budgetMonthSheets.map { $0.budgetSheetView.detailsTableScrollView })
        self.scrollViews.forEach { scrollView in
            scrollView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(
                self, selector:
                #selector(scrollViewBoundsDidChange(_:)),
                name: NSView.boundsDidChangeNotification,
                object: scrollView.contentView)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(budgetCategoryWasRecalculated(_:)),
                                               name: .budgetCategoryWasRecalculated,
                                               object: nil)
        
        self.refreshData()
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
        self.budgetMonthSheets.forEach({ $0.expand(row: row) })
    }
    
    func budgetCategoriesViewController(_ viewController: BudgetCategoriesViewController, willCollapseRow row: Int) {
        self.budgetMonthSheets.forEach({ $0.collapse(row: row) })
    }
    
    @objc func backButtonClicked() {
        self.offsetFromCurrentMonth -= 1
        self.refreshData()
    }
    
    @objc func forwardButtonClicked() {
        self.offsetFromCurrentMonth += 1
        self.refreshData()
    }
    
    @objc func budgetCategoryWasRecalculated(_ notification: Notification) {
        self.refreshData()
    }
    
    func refreshData() {
        let currentDate = Date()
        self.budgetMonthSheets.enumerated().forEach { (i, budgetSheetViewController) in
            let resolvedMonthOffset = i + self.offsetFromCurrentMonth - 1
            guard let date = Calendar.current.date(byAdding: DateComponents(month: resolvedMonthOffset), to: currentDate, wrappingComponents: false) else {
                assertionFailure("Couldn't create a date")
                return
            }
            
            let month = Calendar.current.component(.month, from: date)
            let year = Calendar.current.component(.year, from: date)
            budgetSheetViewController.month = MonthYear(month: month, year: year)
        }
    }
}
