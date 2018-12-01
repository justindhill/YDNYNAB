//
//  BudgetMonthTableDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import AppKit
import GRDB

class BudgetMonthTableDataSource: NSObject, NSOutlineViewDataSource {
    
    var masterCategories: [BudgetMasterCategory]?
    var budgetLines: [BudgetMasterCategory: [BudgetLine]] = [:]
    
    let month: Int
    let year: Int
    let dbQueue: DatabaseQueue
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(monthYear: MonthYear, dbQueue: DatabaseQueue) {
        self.month = monthYear.month
        self.year = monthYear.year
        self.dbQueue = dbQueue
        
        super.init()
        
        masterCategories = self.dbQueue.read{ try? BudgetMasterCategory.order(sql: "sortOrder ASC").fetchAll($0) }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let masterCategories = self.masterCategories else {
            return 0
        }
        
        if item == nil {
            return masterCategories.count
        } else if let item = item as? BudgetMasterCategory {
            return self.dbQueue.read { item.numberOfVisibleSubcategories($0) }
        }
        
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is BudgetMasterCategory
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let masterCategoriesResultSet = self.masterCategories else {
            fatalError()
        }
        
        if item == nil {
            let category = masterCategoriesResultSet[index]
            return category
        } else if let item = item as? BudgetMasterCategory {
            let masterCategoryBudgetLines = self.budgetLinesForVisibleSubcategories(ofMasterCategory: item, inMonth: self.month, year: self.year)
            if 0..<masterCategoryBudgetLines.count ~= index {
                return masterCategoryBudgetLines[index]
            }
        }
        
        return NSObject()
    }
    
    func budgetLinesForVisibleSubcategories(ofMasterCategory masterCategory: BudgetMasterCategory, inMonth month: Int, year: Int) -> [BudgetLine] {
        if let budgetLines = self.budgetLines[masterCategory] {
            return budgetLines
        } else if let results = self.dbQueue.read({ masterCategory.budgetLinesForVisibleSubcategories(inMonth: month, year: year, db: $0) }) {
            self.budgetLines[masterCategory] = results
            return results
        } else {
            return []
        }
    }
    
}
