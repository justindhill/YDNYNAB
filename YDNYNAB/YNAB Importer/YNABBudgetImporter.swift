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
        
//        guard let realm = try? Realm() else {
//            fatalError("Couldn't get the default realm")
//        }
        
        var masterCategories: [String: BudgetMasterCategory] = [:]
        var subCategories: [String: BudgetSubCategory] = [:]
        
//        try! realm.write {
//            var skipLine = true
//            fileContents.split(separator: "\n").forEach { (line) in
//                if skipLine {
//                    skipLine = false
//                    return
//                }
//                
//                if line.contains("Uncategorized Transactions") {
//                    return
//                }
//                
//                let budgetLine = realm.create(BudgetLine.self)
//                
//                var lineMasterCategory: BudgetMasterCategory?
//
//                line.split(separator: ",", omittingEmptySubsequences: false).enumerated().forEach({ (index, value) in
//                    let stringValue = String(value).trimmingCharacters(in: ["\""])
//                    guard let field = Field(rawValue: index) else {
//                        return
//                    }
//                    
//                    switch field {
//                    case .month:
//                        budgetLine.month = self.dateFormatter.date(from: stringValue) ?? Date()
//                    case .masterCategory:
//                        if stringValue != "Hidden Categories" {
//                            let masterCategory: BudgetMasterCategory
//                            if let existingCategory = masterCategories[stringValue] {
//                                masterCategory = existingCategory
//                            } else {
//                                masterCategory = realm.create(BudgetMasterCategory.self)
//                                masterCategory.name = stringValue
//                                masterCategory.sortOrder = masterCategories.count
//                                masterCategories[stringValue] = masterCategory
//                            }
//                            lineMasterCategory = masterCategory
//                            budgetLine.masterCategory = masterCategory
//                        }
//                    case .subCategory:
//                        if budgetLine.masterCategory == nil {
//                            // hidden category
//                            let categoryInfo = stringValue.split(separator: "`").map({$0.trimmingCharacters(in: CharacterSet([" "]))})
//                            guard categoryInfo.count >= 2 else {
//                                return
//                            }
//                            let masterCategoryName = categoryInfo[0]
//                            let subCategoryName = categoryInfo[1]
//                            
//                            let masterCategory: BudgetMasterCategory
//                            if let existingCategory = masterCategories[masterCategoryName] {
//                                masterCategory = existingCategory
//                            } else {
//                                masterCategory = realm.create(BudgetMasterCategory.self)
//                                masterCategory.name = masterCategoryName
//                                masterCategory.sortOrder = masterCategories.count
//                                masterCategories[masterCategoryName] = masterCategory
//                            }
//                            lineMasterCategory = masterCategory
//                            budgetLine.masterCategory = masterCategory
//                            
//                            let subCategory: BudgetSubCategory
//                            if let existingCategory = subCategories[subCategoryName] {
//                                subCategory = existingCategory
//                            } else {
//                                subCategory = realm.create(BudgetSubCategory.self)
//                                subCategory.name = subCategoryName
//                                subCategory.masterCategory = masterCategory
//                                subCategory.isHidden = true
//                                subCategory.sortOrder = masterCategory.subcategories.count
//                                subCategories[subCategoryName] = subCategory
//                            }
//                            budgetLine.subCategory = subCategory
//                            
//                        } else {
//                            // regular category
//                            let subCategory: BudgetSubCategory
//                            if let existingCategory = subCategories[stringValue] {
//                                subCategory = existingCategory
//                            } else {
//                                subCategory = realm.create(BudgetSubCategory.self)
//                                subCategory.name = stringValue
//                                subCategory.masterCategory = lineMasterCategory
//                                subCategory.sortOrder = lineMasterCategory?.subcategories.count ?? -1
//                                subCategories[stringValue] = subCategory
//                            }
//                            budgetLine.subCategory = subCategory
//                        }
//                    case .budgeted:
//                        budgetLine.budgeted.value = self.currencyFormatter.number(from: stringValue)?.doubleValue
//                    case .outflows:
//                        budgetLine.outflows.value = self.currencyFormatter.number(from: stringValue)?.doubleValue
//                    case .balance:
//                        budgetLine.categoryBalance = self.currencyFormatter.number(from: stringValue)?.doubleValue ?? 0
//                    case .category:
//                        break
//                    }
//                })
//                
//                realm.add(budgetLine)
//            }
//        }
    }
}
