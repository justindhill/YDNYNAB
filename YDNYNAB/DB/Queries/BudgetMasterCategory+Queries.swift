//
//  BudgetMasterCategory+Queries.swift
//  YDNYNAB
//
//  Created by Justin Hill on 10/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

extension BudgetMasterCategory {
    
    class func first(withName name: String, inDb db: Database) -> BudgetMasterCategory? {
        do {
            return try BudgetMasterCategory.filter(Column("name") == name).fetchOne(db)
        } catch {
            return nil
        }
    }
    
    func numberOfVisibleSubcategories(_ db: Database) -> Int {
        guard let id = self.id else {
            return 0
        }
        
        if let count = try? BudgetSubCategory
            .filter(sql: "isHidden = false AND masterCategory = ?", arguments: [id])
            .fetchCount(db) {
            return count
        } else {
            return 0
        }
    }
    
    func visibleSubcategories(_ db: Database) -> [BudgetSubCategory]? {
        guard let id = self.id else {
            return []
        }
        
        return try? BudgetSubCategory.fetchAll(db,
            """
            SELECT * from budgetSubCategory
            WHERE isHidden = false AND masterCategory = ?
            ORDER BY sortOrder ASC
            """, arguments: [id])
    }
    
    func budgetLinesForVisibleSubcategories(inMonth month: Int, year: Int, db: Database) -> [BudgetLine]? {
        guard let id = self.id else {
            return []
        }
        
        return try? BudgetLine.fetchAll(db,
            """
            SELECT budgetLine.*, date(budgetLine.month) as monthDate from budgetLine
            LEFT JOIN budgetSubCategory ON budgetSubCategory.id = budgetLine.subcategory
            WHERE monthDate = date(?) AND budgetLine.masterCategory = ? AND budgetSubCategory.isHidden = false
            ORDER BY budgetSubCategory.sortOrder ASC
            """, arguments: StatementArguments([DateUtils.dateString(withMonth: month, year: year), id]))
    }
    
}
