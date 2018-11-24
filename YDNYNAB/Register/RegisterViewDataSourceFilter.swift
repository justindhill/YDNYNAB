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
        let subcategoryId: Int64?
        
        init(startDate: Date? = nil,
             endDate: Date? = nil,
             subcategory: Int64? = nil) {
            self.startDate = startDate
            self.endDate = endDate
            self.subcategoryId = subcategory
        }
        
        var components: (String, [Any]) {
            var filterString = ""
            var filterValues: [Any] = []
            
            func addTerm(_ term: String, _ values: Any...) {
                if filterString.isEmpty {
                    filterString = "WHERE \(term)"
                } else {
                    filterString += " AND \(term)"
                }
                filterValues.append(contentsOf: values)
            }
            
            if let startDate = self.startDate, let endDate = self.endDate {
                addTerm("(date(date) >= ? AND date(date) <= ?)",
                        DateUtils.dateString(withDate: startDate),
                        DateUtils.dateString(withDate: endDate))
            } else if let startDate = self.startDate {
                addTerm("date(date) >= ?", DateUtils.dateString(withDate: startDate))
            } else if let endDate = self.endDate {
                addTerm("date(date) <= ?", DateUtils.dateString(withDate: endDate))
            }
            
            if let subcategoryId = self.subcategoryId {
                addTerm("subCategory = ?", subcategoryId)
            }
            
            return (filterString, filterValues)
        }
    }
    
}
