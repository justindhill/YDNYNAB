//
//  MonthYear.swift
//  YDNYNAB
//
//  Created by Justin Hill on 12/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

struct MonthYear {
    static let utcCalendar: Calendar = {
        guard let utcTimeZone = TimeZone(secondsFromGMT: 0) else {
            fatalError("Couldn't get the UTC time zone.")
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimeZone
        return calendar
    }()
    
    let month: Int
    let year: Int
    
    var date: Date {
        return DateUtils.date(withMonth: self.month, year: self.year)
    }
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    init(date: Date) {
        self.month = MonthYear.utcCalendar.component(.month, from: date)
        self.year = MonthYear.utcCalendar.component(.year, from: date)
    }
    
    func incrementingMonth() -> MonthYear {
        guard let date = MonthYear.utcCalendar.date(byAdding: DateComponents(month: 1), to: self.date, wrappingComponents: false) else {
            fatalError("Adding a month to a date should always produce a valid date")
        }
        
        return MonthYear(date: date)
    }
    
    static let zero = MonthYear(month: 0, year: 0)
}
