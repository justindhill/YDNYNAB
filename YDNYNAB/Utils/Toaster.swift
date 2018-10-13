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
        print("Something bad happened, but the toaster doesn't do anything yet!")
    }
}
