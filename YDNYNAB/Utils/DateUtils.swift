//
//  DateUtils.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/9/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class DateUtils: NSObject {
    class func threeLetterAbbreviation(forMonth month: Int) -> String {
        switch month {
        case 1: return "JAN"
        case 2: return "FEB"
        case 3: return "MAR"
        case 4: return "APR"
        case 5: return "MAY"
        case 6: return "JUN"
        case 7: return "JUL"
        case 8: return "AUG"
        case 9: return "SEP"
        case 10: return "OCT"
        case 11: return "NOV"
        case 12: return "DEC"
        default: return ""
        }
    }
    
    class func date(withMonth month: Int, year: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current, year: year, month: month, day: 1)
        
        guard let date = components.date else {
            fatalError("Somehow this month and year don't produce a valid date.")
        }
        
        return date
    }
}
