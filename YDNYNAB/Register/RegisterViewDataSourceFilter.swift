//
//  RegisterViewDataSourceFilter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 10/13/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

extension RegisterViewDataSource {
    
    struct Filter {
        let startDate: Date?
        let endDate: Date?
        let subcategory: BudgetSubCategory?
        
        init(startDate: Date? = nil,
             endDate: Date? = nil,
             subcategory: BudgetSubCategory? = nil) {
            self.startDate = startDate
            self.endDate = endDate
            self.subcategory = subcategory
        }
        
        var filterPredicate: NSPredicate {
            var filterString = ""
            var filterValues: [Any] = []
            
            func addTerm(_ term: String, _ values: Any...) {
                if filterString.isEmpty {
                    filterString = term
                } else {
                    filterString += " AND \(term)"
                }
                filterValues.append(contentsOf: values)
            }
            
            if let startDate = self.startDate, let endDate = self.endDate {
                addTerm("(date >= %@ AND date <= %@)", startDate, endDate)
            } else if let startDate = self.startDate {
                addTerm("date >= %@", startDate)
            } else if let endDate = self.endDate {
                addTerm("date <= %@", endDate)
            }
            
            if let subcategory = self.subcategory {
                addTerm("subCategory = %@", subcategory)
            }
            
            return NSPredicate(format: filterString, argumentArray: filterValues)
        }
    }
    
}
