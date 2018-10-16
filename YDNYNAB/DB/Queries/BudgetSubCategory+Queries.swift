//
//  BudgetSubCategory+Queries.swift
//  YDNYNAB
//
//  Created by Justin Hill on 10/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

extension BudgetSubCategory {
    
    class func first(withName name: String, inDb db: Database) -> BudgetSubCategory? {
        do {
            return try BudgetSubCategory.filter(Column("name") == name).fetchOne(db)
        } catch {
            return nil
        }
    }
    
}
