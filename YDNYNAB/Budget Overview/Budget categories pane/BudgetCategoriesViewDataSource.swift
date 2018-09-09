//
//  BudgetCategoriesViewDataSource.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class BudgetCategoriesViewDataSource: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {//NSTableViewDataSource, NSTableViewDelegate {
    
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
            return item.subcategories.count
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
            return item.subcategories[index]
        } else {
            return NSObject()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item is BudgetMasterCategory)
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowView = MonthBudgetTableRowView(row: 0)
        if item is BudgetMasterCategory {
            rowView.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.25)
        }
        
        return rowView
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = MonthBudgetCurrencyTableCellView()
        if let item = item as? BudgetMasterCategory {
            cellView.currencyTextField.stringValue = item.name
            cellView.currencyTextField.font = NSFont.boldSystemFont(ofSize: 12)

        } else if let item = item as? BudgetSubCategory {
            cellView.currencyTextField.stringValue = item.name
            cellView.currencyTextField.font = NSFont.systemFont(ofSize: 12)
        }

        return cellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is BudgetMasterCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is BudgetMasterCategory {
            return 28
        } else {
            return 22
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false
    }

}
    
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return self.resultSet?.count ?? 0
//    }
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        guard let resultSet = self.resultSet else {
//            return nil
//        }
//
//        let subCategory = resultSet[row]
//
//        let cellView = NSTextField(labelWithString: subCategory.name)
//        cellView.cell?.truncatesLastVisibleLine = true
//        cellView.cell?.lineBreakMode = .byTruncatingTail
//
//        return cellView
//    }
//
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//    }
//
//    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        return 25
//    }
//
//}

