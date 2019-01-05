//
//  OFXImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/2/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa
import libofx

class OFXImporter: NSObject {

    class func `import`(budgetContext: BudgetContext) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["qfx", "ofx"]
        openPanel.begin { response in
            guard response == .OK, let fileURL = openPanel.url, fileURL.isFileURL else {
                return
            }
            
            let reader = OFXReader(fileURL: fileURL)
            reader.accounts.first?.statements.forEach { statement in
                print(statement.transactions)
            }
        }
    }
    
}
