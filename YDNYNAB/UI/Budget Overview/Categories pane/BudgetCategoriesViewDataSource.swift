//
//  BudgetCategoriesViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB
import AppKit

class BudgetCategoriesViewDataSource: NSObject, NSOutlineViewDataSource {
    
    var dbQueue: DatabaseQueue
    
    var masterCategories: [BudgetMasterCategory]?
    var subCategories: [BudgetMasterCategory: [BudgetSubCategory]] = [:]

    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue

        super.init()
        
        self.masterCategories = dbQueue.read { (db) -> [BudgetMasterCategory]? in
            return try? BudgetMasterCategory
                .filter(Column("isHidden") == false)
                .fetchAll(db)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let resultSet = self.masterCategories, item == nil {
            return resultSet.count
        } else if let item = item as? BudgetMasterCategory {
            return self.visibleSubcategories(forMasterCategory: item).count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let resultSet = masterCategories else {
            fatalError()
        }

        if item == nil {
            return resultSet[index]
        } else if let item = item as? BudgetMasterCategory {
            return self.visibleSubcategories(forMasterCategory: item)[index]
        } else {
            return NSObject()
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item is BudgetMasterCategory)
    }
    
    func visibleSubcategories(forMasterCategory masterCategory: BudgetMasterCategory) -> [BudgetSubCategory] {
        if let subCategories = self.subCategories[masterCategory] {
            return subCategories
        } else {
            if let subCategories = self.dbQueue.read({ masterCategory.visibleSubcategories($0) }) {
                self.subCategories[masterCategory] = subCategories
                return subCategories
            }
        }
        
        return []
    }

}
