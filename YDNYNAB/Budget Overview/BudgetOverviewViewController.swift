//
//  BudgetOverviewViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetOverviewViewController: NSViewController {
    
    override func loadView() {
        self.view = BudgetOverviewView()
    }
    
    var budgetOverviewView: BudgetOverviewView {
        return self.view as! BudgetOverviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.budgetOverviewView.monthBudgetSheets.forEach { monthBudgetSheet in
            NotificationCenter.default.addObserver(
                self, selector:
                #selector(scrollViewBoundsDidChange(_:)),
                name: NSView.boundsDidChangeNotification,
                object: monthBudgetSheet.budgetSheetView.detailsTableScrollView.contentView)
        }
    }
    
    @objc func scrollViewBoundsDidChange(_ note: Notification) {
        guard let contentView = note.object as? NSClipView else {
            return
        }
        
        self.budgetOverviewView.monthBudgetSheets.forEach { monthBudgetSheet in
            let candidate = monthBudgetSheet.budgetSheetView.detailsTableScrollView.contentView
            if let candidateScrollView = candidate.superview as? NSScrollView, candidate != contentView {
                candidate.scroll(to: contentView.bounds.origin)
                candidateScrollView.reflectScrolledClipView(candidate)
            }
        }
    }
    
}
