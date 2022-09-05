//
//  OFXImporter.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/2/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa
import libofx
import GRDB
import UniformTypeIdentifiers

class OFXImporter: NSObject {

    class func `import`(budgetContext: BudgetContext) {
        guard let qfx = UTType(filenameExtension: "qfx"),
              let ofx = UTType(filenameExtension: "ofx"),
              let qif = UTType(filenameExtension: "qif") else {
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [qfx, ofx, qif]
        openPanel.begin { response in
            guard response == .OK, let fileURL = openPanel.url, fileURL.isFileURL else {
                return
            }
            
            let reader = OFXReader(fileURL: fileURL)
            
            do {
                try budgetContext.database.queue.write { db in
                    try reader.accounts.first?.statements.forEach { statement in
                        try statement.transactions.forEach { transaction in
                            if let _ = self.existingTransaction(matching: transaction, in: db) {
                                
                            } else {
                                let newTransaction = Transaction(ofxTransaction: transaction)
                                newTransaction.payee = try self.newOrExistingPayee(matching: transaction.payeeName, in: db).id
                                try newTransaction.insert(db)
                            }
                        }                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    fileprivate class func newOrExistingPayee(matching name: String, in db: Database) throws -> Payee {
        if let existingPayee = try Payee.payee(withName: name, inDb: db) {
            return existingPayee
        } else {
            let newPayee = Payee()
            newPayee.name = name
            try newPayee.insert(db)
            
            return newPayee
        }
    }
    
    fileprivate class func existingTransaction(matching: OFXTransaction, in db: Database) -> Transaction? {
        return nil
    }
    
}
