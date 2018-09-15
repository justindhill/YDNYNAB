//
//  MonthBudgetTableDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import RealmSwift

class MonthBudgetTableDataSource: NSObject, NSOutlineViewDataSource {
    
    var masterCategories: Results<BudgetMasterCategory>?
    var budgetLineQueries: [String: Results<BudgetLine>] = [:]
    var stupidMap: [Int: BudgetMasterCategory] = [:]
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required override init() {
        super.init()
        let sortDescriptors = [
            SortDescriptor(keyPath: "name", ascending: true)
        ]
        
        self.masterCategories = try? Realm()
            .objects(BudgetMasterCategory.self)
            .sorted(by: sortDescriptors)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let masterCategories = self.masterCategories else {
            return 0
        }
        
        if item == nil {
            return masterCategories.count
        } else if let item = item as? BudgetMasterCategory {
            return item.subcategories.count
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
            if let category = stupidMap[index] {
                return category
            } else {
                let category = masterCategoriesResultSet[index]
                stupidMap[index] = category
                return category
            }

        } else if let item = item as? BudgetMasterCategory {
            let subcategory = item.subcategories[index]
            
            var resultSet: Results<BudgetLine>?
            if let cachedResults = self.budgetLineQueries[subcategory.id] {
                resultSet = cachedResults
            } else if let freshResults = try? Realm().objects(BudgetLine.self).filter("subCategory = %@ AND month = %@", subcategory, DateUtils.date(withMonth: 1, year: 2018)) {
                self.budgetLineQueries[subcategory.id] = freshResults
                resultSet = freshResults
            }
            
            if let resultSet = resultSet,
                let budgetLine = resultSet.first {
                return budgetLine
            }
        }
        
        return NSObject()
    }
    
}
