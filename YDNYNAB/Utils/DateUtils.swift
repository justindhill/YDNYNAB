//
//  DateUtils.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/9/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class DateUtils: NSObject {
    class func date(withMonth month: Int, year: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current, year: year, month: month, day: 1)
        
        guard let date = components.date else {
            fatalError("Somehow this month and year don't produce a valid date.")
        }
        
        return date
    }
}
