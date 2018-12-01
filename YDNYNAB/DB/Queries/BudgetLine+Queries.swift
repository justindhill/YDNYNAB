//
//  BudgetLine+Queries.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

extension BudgetLine {
    
    class func budgetLines(forSubcategory subcategoryId: Int64, inDb db: Database) throws -> [BudgetLine] {        
        return try BudgetLine
            .filter(sql: "subcategory = ?", arguments: StatementArguments([subcategoryId]))
            .order(Column("month").asc)
            .fetchAll(db)
    }
    
}
