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
    
    static let UncategorizedCategoryId: Int64 = 1
    static let IncomeCategoryId: Int64 = 2
    static let SplitCategoryId: Int64 = 3
    
    let budgetWrapper: BudgetPackageWrapper
    lazy var queue = try! DatabaseQueue(path: self.budgetWrapper.mainDatabaseFileURL.path)
    
    required init(coder: NSCoder) { fatalError("not implemented") }
    init(budgetWrapper: BudgetPackageWrapper) {
        self.budgetWrapper = budgetWrapper
        super.init()
        
        if !FileManager.default.fileExists(atPath: self.budgetWrapper.mainDatabaseFileURL.path) {
            try! self.queue.write { db in
                try self.createTables(inDb: db)
                try self.primeTables(inDb: db)
            }
        }
    }
    
    func createTables(inDb db: Database) throws {
        try db.create(table: BudgetMasterCategory.databaseTableName) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull().defaults(to: "")
            t.column("sortOrder").notNull().defaults(to: "-1")
            t.column("isHidden").notNull().defaults(to: false)
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
            t.column("accountId", .text)
        }
        
        try db.create(table: Payee.databaseTableName) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text)
        }
        
        try db.create(table: PayeeRenameRule.databaseTableName) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("type", .text)
            t.column("criterion", .text)
        }
        
        try db.create(table: Transaction.databaseTableName) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("flag", .text)
            t.column("checkNumber", .text)
            t.column("date", .date)
            t.column("effectiveDate", .date)
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
            t.column("splitParent", .integer).indexed()
            t.foreignKey(["splitParent"],
                         references: Transaction.databaseTableName,
                         columns: ["id"],
                         onDelete: .cascade,
                         onUpdate: nil,
                         deferred: false)
        }
    }
    
    func primeTables(inDb db: Database) throws {
        let uncategorizedMasterCategory = BudgetMasterCategory()
        uncategorizedMasterCategory.name = "Uncategorized Transactions"
        uncategorizedMasterCategory.isHidden = true
        try uncategorizedMasterCategory.insert(db)
        
        let uncategorizedSubcategory = BudgetSubCategory()
        uncategorizedSubcategory.name = "No category"
        uncategorizedSubcategory.masterCategory = uncategorizedMasterCategory.id
        uncategorizedSubcategory.isHidden = true
        try uncategorizedSubcategory.insert(db)
        
        let incomeMasterCategory = BudgetMasterCategory()
        incomeMasterCategory.name = "Income"
        incomeMasterCategory.isHidden = true
        try incomeMasterCategory.insert(db)
        
        let incomeSubcategory = BudgetSubCategory()
        incomeSubcategory.name = ""
        incomeSubcategory.masterCategory = incomeMasterCategory.id
        incomeSubcategory.isHidden = true
        try incomeSubcategory.insert(db)
        
        let splitMasterCategory = BudgetMasterCategory()
        splitMasterCategory.name = "Split"
        splitMasterCategory.isHidden = true
        try splitMasterCategory.insert(db)
        
        let splitSubcategory = BudgetSubCategory()
        splitSubcategory.name = "(Multiple categories)"
        splitSubcategory.masterCategory = splitMasterCategory.id
        splitSubcategory.isHidden = true
        try splitSubcategory.insert(db)
        
        let defaultAccount = Account()
        defaultAccount.name = "Test account"
        try defaultAccount.insert(db)
    }

}
