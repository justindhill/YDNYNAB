//
//  Transaction+OFX.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/5/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Foundation
import libofx

extension Transaction {
    
    convenience init(ofxTransaction ofx: OFXTransaction) {
        self.init()
        
        self.account = 1
        self.masterCategory = 1 // uncategorized
        self.subCategory = 1 // uncategorized
        self.checkNumber = ofx.checkNumber
        self.memo = ofx.memo
        
        if ofx.amount > 0 {
            self.inflow = ofx.amount
        } else if ofx.amount < 0 {
            self.outflow = ofx.amount
        }
        
        if let date = ofx.datePosted {
            self.date = date
            self.cleared = true
        }
    }
    
}
