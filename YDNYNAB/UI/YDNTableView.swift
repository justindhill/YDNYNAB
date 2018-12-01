//
//  YDNTableView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 11/25/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class YDNTableView: NSTableView {

    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        // let cells handle their own clicks
        return true
    }
    
}
