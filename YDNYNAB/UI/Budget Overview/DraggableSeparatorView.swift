//
//  DraggableSeparatorView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/8/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class DraggableSeparatorView: NSView {

    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func updateTrackingAreas() {
        self.tracksMouseMovement = true
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.resizeLeftRight.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.arrow.set()
    }
    
}
