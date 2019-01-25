//
//  Toaster.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/27/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class Toaster: NSObject {
    static let shared = Toaster()
    
    func enqueueDefaultErrorToast() {
        let alert = NSAlert()
        alert.messageText = "That didn't work. Try again?"
    }
}
