//
//  NSView+Extensions.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

extension NSView {
    
    var tracksMouseMovement: Bool {
        set {
            if newValue == self.tracksMouseMovement {
                return
            }
            
            self.trackingAreas.forEach { self.removeTrackingArea($0) }

            if newValue {
                self.addTrackingArea(
                    NSTrackingArea(
                        rect: self.bounds,
                        options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved],
                        owner: self,
                        userInfo: nil
                    )
                )
            }
        }
        
        get {
            return self.trackingAreas.count > 0
        }
    }
    
}
