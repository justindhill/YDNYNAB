//
//  BudgetPackageWrapper.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/1/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetPackageWrapper: NSObject {
    
    let fileUrl: URL
    
    init(path: String) throws {
        self.fileUrl = URL(fileURLWithPath: path)
        
        super.init()
        
        if !FileManager.default.fileExists(atPath: self.fileUrl.path) {
            throw NSError()
        }
    }
    
    var mainDatabaseFileURL: URL {
        return self.fileUrl.appendingPathComponent("main.db")
    }

}
