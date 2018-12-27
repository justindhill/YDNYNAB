//
//  YNABBudgetImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import GRDB


class YNABBudgetImporter {
    enum Field: Int {
        case month
        case category
        case masterCategory
        case subCategory
        case budgeted
        case outflows
        case balance
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }()
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    init(csvFileUrl: URL) {
        guard let fileContents = try? String(contentsOf: csvFileUrl) else {
            fatalError("Couldn't get file contents")
        }
        
        guard let dbQueue = try? DatabaseQueue(path: "/Users/justin/Desktop/test.db") else {
            fatalError("Couldn't open the db queue")
        }
        
        var masterCategories: [String: BudgetMasterCategory] = [:]
        var subCategories: [String: BudgetSubCategory] = [:]
        
        dbQueue.write { db in
            var skipLine = true
            var previousMonthBudgetLines: [BudgetSubCategory: BudgetLine] = [:]
            
            try! fileContents.split(separator: "\n").forEach { (line) in
                if skipLine {
                    skipLine = false
                    return
                }

                if line.contains("Uncategorized Transactions") {
                    return
                }

                let budgetLine = BudgetLine()

                var lineMasterCategory: BudgetMasterCategory?
                var lineSubcategory: BudgetSubCategory?

                try line.split(separator: ",", omittingEmptySubsequences: false).enumerated().forEach({ (index, value) in
                    let stringValue = String(value).trimmingCharacters(in: ["\""])
                    guard let field = Field(rawValue: index) else {
                        return
                    }

                    switch field {
                    case .month:
                        budgetLine.month = self.dateFormatter.date(from: stringValue) ?? Date()
                        print(budgetLine.month)
                    case .masterCategory:
                        if stringValue != "Hidden Categories" {
                            let masterCategory: BudgetMasterCategory
                            if let existingCategory = masterCategories[stringValue] {
                                masterCategory = existingCategory
                            } else {
                                masterCategory = BudgetMasterCategory()
                                masterCategory.name = stringValue
//                                masterCategory.sortOrder = masterCategories.count
                                masterCategories[stringValue] = masterCategory
                                try masterCategory.insert(db)
                            }
                            lineMasterCategory = masterCategory
                            budgetLine.masterCategory = masterCategory.id
                        }
                    case .subCategory:
                        if budgetLine.masterCategory == nil {
                            // hidden category
                            let categoryInfo = stringValue.split(separator: "`").map({$0.trimmingCharacters(in: CharacterSet([" "]))})
                            guard categoryInfo.count >= 2 else {
                                return
                            }
                            let masterCategoryName = categoryInfo[0]
                            let subCategoryName = categoryInfo[1]

                            let masterCategory: BudgetMasterCategory
                            if let existingCategory = masterCategories[masterCategoryName] {
                                masterCategory = existingCategory
                            } else {
                                masterCategory = BudgetMasterCategory()
                                masterCategory.name = masterCategoryName
//                                masterCategory.sortOrder = masterCategories.count
                                masterCategories[masterCategoryName] = masterCategory
                                try masterCategory.insert(db)
                            }
                            lineMasterCategory = masterCategory
                            budgetLine.masterCategory = masterCategory.id

                            let subCategory: BudgetSubCategory
                            if let existingCategory = subCategories[subCategoryName] {
                                subCategory = existingCategory
                            } else {
                                subCategory = BudgetSubCategory()
                                subCategory.name = subCategoryName
                                subCategory.masterCategory = masterCategory.id
                                subCategory.isHidden = true
//                                subCategory.sortOrder = masterCategory.subcategories.count
                                subCategories[subCategoryName] = subCategory
                                try subCategory.insert(db)
                            }
                            budgetLine.subcategory = subCategory.id
                            lineSubcategory = subCategory

                        } else {
                            // regular category
                            let subCategory: BudgetSubCategory
                            if let existingCategory = subCategories[stringValue] {
                                subCategory = existingCategory
                            } else {
                                subCategory = BudgetSubCategory()
                                subCategory.name = stringValue
                                subCategory.masterCategory = lineMasterCategory?.id
//                                subCategory.sortOrder = lineMasterCategory?.subcategories.count ?? -1
                                subCategories[stringValue] = subCategory
                                try subCategory.insert(db)
                            }
                            budgetLine.subcategory = subCategory.id
                            lineSubcategory = subCategory
                        }
                    case .budgeted:
                        budgetLine.budgeted = self.currencyFormatter.number(from: stringValue)?.doubleValue
                    case .outflows:
                        let outflows = self.currencyFormatter.number(from: stringValue)?.doubleValue
                        budgetLine.outflows = outflows
                    case .balance:
                        budgetLine.categoryBalance = self.currencyFormatter.number(from: stringValue)?.doubleValue ?? 0
                    case .category:
                        break
                    }
                })
                
                if let lineSubcategory = lineSubcategory {
                    if let previousBudgetLine = previousMonthBudgetLines[lineSubcategory] {
                        let previousMonthBalance = previousBudgetLine.categoryBalance
                        let currentMonthBudgeted = budgetLine.budgeted ?? 0
                        let currentMonthOutflows = budgetLine.outflows ?? 0
                        let currentMonthStartValue = budgetLine.categoryBalance + currentMonthOutflows - currentMonthBudgeted
                        
                        if previousMonthBalance < 0 {
                            // cover any silly precision problems that nsnumber is giving us
                            let carriesOverNegativeBalance = !(0..<0.001 ~= abs(currentMonthStartValue))
                            
                            budgetLine.carriesOverNegativeBalance = carriesOverNegativeBalance

                            if previousBudgetLine.carriesOverNegativeBalance != carriesOverNegativeBalance {
                                previousBudgetLine.carriesOverNegativeBalance = carriesOverNegativeBalance
                                try previousBudgetLine.update(db)
                            }
                        } else {
                            budgetLine.carriesOverNegativeBalance = previousBudgetLine.carriesOverNegativeBalance
                        }
                    }
                    
                    previousMonthBudgetLines[lineSubcategory] = budgetLine
                }

                try budgetLine.insert(db)
            }
        }
    }
}