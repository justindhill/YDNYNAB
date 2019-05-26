//
//  YDNOutlineView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class YDNOutlineView: NSOutlineView {

    var selectsChildrenOfSelectedExpandedParent: Bool = false
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
    
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        // let cells handle their own clicks
        return true
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
    
    override func expandItem(_ item: Any?, expandChildren: Bool) {
        super.expandItem(item, expandChildren: expandChildren)
        
        if self.selectsChildrenOfSelectedExpandedParent && self.selectedRow == self.row(forItem: item) {
            var indexesToSelect = IndexSet()
            
            for i in 0..<self.numberOfChildren(ofItem: item) {
                if let childItem = self.child(i, ofItem: item) {
                    let childItemIndex = self.row(forItem: childItem)
                    
                    if childItemIndex >= 0 {
                        indexesToSelect.insert(childItemIndex)
                    } else {
                        print("Tried to select child, but childItemIndex was <0")
                    }
                }
            }
            
            self.selectRowIndexes(indexesToSelect, byExtendingSelection: true)
        }
    }
    
    func topLevelItem(forRow row: Int) -> Any? {
        guard let item = self.item(atRow: row) else {
            return nil
        }
        
        return self.topLevelItem(forItem: item)
    }
    
    func topLevelItem(forItem item: Any) -> Any {
        if let parent = self.parent(forItem: item) {
            return parent
        }
        
        return item
    }
    
    /**
     Rows in the outline view associated with the item. If the item is currently expanded, this includes the item's
     children. If it is collapsed, it does not. If the item is a child, the rows include its parent and its siblings.
     */
    func rows(forItem item: Any) -> IndexSet {
        let topLevelItem = self.topLevelItem(forItem: item)
        var rows = IndexSet(integer: self.row(forItem: topLevelItem))
        let childCount = self.numberOfChildren(ofItem: topLevelItem)
        
        if childCount > 0 && self.isItemExpanded(topLevelItem) {
            for i in 0..<childCount {
                let childItem = self.child(i, ofItem: topLevelItem)
                rows.insert(self.row(forItem: childItem))
            }
        }
        
        return rows
    }
    
}
