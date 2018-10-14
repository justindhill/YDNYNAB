//
//  BudgetCategoriesViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class BudgetCategoriesViewDataSource: NSObject, NSOutlineViewDataSource {//NSTableViewDataSource, NSTableViewDelegate {
    
    var resultSet: Results<BudgetMasterCategory>?
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required override init() {
        super.init()
        
        resultSet = try? Realm()
            .objects(BudgetMasterCategory.self)
            .sorted(by: [SortDescriptor(keyPath: "name", ascending: true)])
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let resultSet = self.resultSet, item == nil {
            return resultSet.count
        } else if let item = item as? BudgetMasterCategory {
            return item.visibleSubcategories.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let resultSet = resultSet else {
            fatalError()
        }
        
        if item == nil {
            return resultSet[index]
        } else if let item = item as? BudgetMasterCategory {
            return item.visibleSubcategories[index]
        } else {
            return NSObject()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item is BudgetMasterCategory)
    }

}
