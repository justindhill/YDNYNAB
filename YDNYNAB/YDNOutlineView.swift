//
//  YDNOutlineView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class YDNOutlineView: NSOutlineView {

    var showsDisclosureIndicator: Bool = true
    private var hoveredView: Hoverable?
    
    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        if self.showsDisclosureIndicator {
            return super.frameOfOutlineCell(atRow: row)
        } else {
            return .zero
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.updateHoveredView(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.updateHoveredView(with: event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.updateHoveredView(with: event)
    }
    
    func updateHoveredView(with event: NSEvent) {
        let locationInSelf = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: locationInSelf)
        let column = self.column(at: locationInSelf)
        
        guard row >= 0 && column >= 0 else {
            return
        }
        
        let view = self.view(atColumn: column, row: row, makeIfNecessary: false)
        
        if let view = view as? Hoverable {
            if self.hoveredView !== view {
                self.hoveredView?.leaveHoverState()
                view.enterHoverState()
                self.hoveredView = view
            }
        } else {
            self.hoveredView?.leaveHoverState()
        }
    }
    
}
