//
//  BudgetUpdater.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class BudgetUpdater: NSObject {
    
    let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func updateBudgetLineAndRecalculateCategory(_ budgetLineToUpdate: BudgetLine) throws {
        guard let subcategoryId = budgetLineToUpdate.subcategory else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "budgetLine doesn't have a subcategory id."])
        }
        
        try self.dbQueue.write { (db) -> Void in
            try budgetLineToUpdate.save(db)

            let budgetLines = try BudgetLine.budgetLines(forSubcategory: subcategoryId, inDb: db)
            
            var previousMonthBalance: Double = 0
            for budgetLine in budgetLines {
                if let outflows = budgetLine.outflows {
                    let budgeted = budgetLine.budgeted ?? 0
                    budgetLine.categoryBalance = previousMonthBalance - outflows + budgeted
                    previousMonthBalance = budgetLine.categoryBalance
                } else {
                    budgetLine.categoryBalance = previousMonthBalance
                }
                
                try budgetLine.save(db)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: .budgetCategoryWasRecalculated, object: nil, userInfo: [ChangedBudgetSubcategoryKey: subcategoryId]))
            }
        }
    }

}

fileprivate let ChangedBudgetSubcategoryKey = "YDNChangedBudgetSubcategory"
extension Notification {
    var recalculatedSubcategory: Int64? {
        get { return self.userInfo?[ChangedBudgetSubcategoryKey] as? Int64 }
    }
}

extension Notification.Name {
    static let budgetCategoryWasRecalculated = Notification.Name(rawValue: "YDNBudgetCategoryWasRecalculatedNotification")
}
