//
//  MonthYear.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

struct MonthYear {
    let month: Int
    let year: Int
    
    var date: Date {
        return DateUtils.date(withMonth: self.month, year: self.year)
    }
    
    static let zero = MonthYear(month: 0, year: 0)
}
