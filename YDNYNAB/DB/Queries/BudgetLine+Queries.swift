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
    
    class func budgetLine(forSubcategory subcategoryId: Int64, month: Int, year: Int, inDb db: Database) throws -> BudgetLine? {
        let month = DateUtils.date(withMonth: month, year: year)
        guard let arguments = StatementArguments([subcategoryId, month]) else {
            return nil
        }
        
        return try BudgetLine
            .filter(sql: "subcategory = ? AND month = ?", arguments: arguments)
            .fetchOne(db)
    }
    
}
