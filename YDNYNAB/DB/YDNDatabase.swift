//
//  YDNDatabase.swift
//  YDNYNAB
//
//  Created by Justin Hill on 10/14/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import GRDB

class YDNDatabase: NSObject {
    
    let budgetWrapper: BudgetPackageWrapper
    lazy var queue = try! DatabaseQueue(path: self.budgetWrapper.mainDatabaseFileURL.path)
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetWrapper: BudgetPackageWrapper) {
        self.budgetWrapper = budgetWrapper
        super.init()
        
        if !FileManager.default.fileExists(atPath: self.budgetWrapper.mainDatabaseFileURL.path) {
            self.createTables()
        }
    }
    
    func createTables() {
        try! self.queue.write { db in
            try db.create(table: BudgetMasterCategory.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().defaults(to: "")
                t.column("sortOrder").notNull().defaults(to: "-1")
            }
            
            try db.create(table: BudgetSubCategory.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().defaults(to: "")
                t.column("sortOrder", .integer).notNull().defaults(to: "-1")
                t.column("isHidden", .boolean).notNull().defaults(to: false)
                t.column("masterCategory", .integer)
                t.foreignKey(["masterCategory"],
                             references: BudgetMasterCategory.databaseTableName,
                             columns: ["id"],
                             onDelete: .cascade,
                             onUpdate: nil,
                             deferred: false)
            }
            
            try db.create(table: BudgetLine.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("month", .date).notNull().defaults(to: Date())
                t.column("budgeted", .double)
                t.column("outflows", .double)
                t.column("categoryBalance", .double)
                t.column("masterCategory", .integer)
                t.foreignKey(["masterCategory"],
                             references: BudgetMasterCategory.databaseTableName,
                             columns: ["id"],
                             onDelete: .cascade,
                             onUpdate: nil,
                             deferred: false)
                t.column("subcategory", .integer)
                t.column("carriesOverNegativeBalance", .boolean)
                t.foreignKey(["subcategory"],
                             references: BudgetSubCategory.databaseTableName,
                             columns: ["id"],
                             onDelete: .cascade,
                             onUpdate: nil,
                             deferred: false)
            }
            
            try db.create(table: Account.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
            }
            
            try db.create(table: Payee.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
            }
            
            try db.create(table: Transaction.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("flag", .text)
                t.column("checkNumber", .text)
                t.column("date", .date)
                t.column("memo", .text)
                t.column("outflow", .integer)
                t.column("inflow", .integer)
                t.column("cleared", .boolean).notNull().defaults(to: false)
                t.column("account", .integer)
                t.foreignKey(["account"],
                             references: Account.databaseTableName,
                             columns: ["id"],
                             onDelete: .setNull,
                             onUpdate: nil,
                             deferred: false)
                t.column("payee", .integer)
                t.foreignKey(["payee"],
                             references: Payee.databaseTableName,
                             columns: ["id"],
                             onDelete: .setNull,
                             onUpdate: nil,
                             deferred: false)
                t.column("masterCategory", .integer)
                t.foreignKey(["masterCategory"],
                             references: BudgetMasterCategory.databaseTableName,
                             columns: ["id"],
                             onDelete: .setNull,
                             onUpdate: nil,
                             deferred: false)
                t.column("subcategory", .integer).indexed()
                t.foreignKey(["subcategory"],
                             references: BudgetSubCategory.databaseTableName,
                             columns: ["id"],
                             onDelete: .setNull,
                             onUpdate: nil,
                             deferred: false)
            }
        }
    }

}
