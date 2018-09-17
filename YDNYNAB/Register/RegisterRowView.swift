//
//  RegisterRowView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterRowView: NSTableRowView {
    
    private var doneButton: NSButton?
    private var cancelButton: NSButton?
    
    var isEditing: Bool = false {
        didSet { self.updateEditingState() }
    }

    enum Constant {
        static let collapsedHeight: CGFloat = 25
        static let expandedHeight: CGFloat = 50
    }
    
    func updateEditingState() {
        self.selectionHighlightStyle = .sourceList
        if self.isEditing && self.doneButton == nil {
            let doneButton = NSButton(title: "Done", target: nil, action: nil)
            self.doneButton = doneButton
            
            let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
            self.cancelButton = cancelButton
            
            self.addSubview(doneButton)
            self.addSubview(cancelButton)
            
            cancelButton.snp.makeConstraints { cancelButton in
                cancelButton.bottom.equalTo(self.snp.top).offset(Constant.expandedHeight - 4)
                cancelButton.right.equalTo(self).offset(-4)
            }
            
            doneButton.snp.makeConstraints { doneButton in
                doneButton.bottom.equalTo(self.snp.top).offset(Constant.expandedHeight - 4)
                doneButton.right.equalTo(cancelButton.snp.left).offset(-4)
            }
            
        } else if !self.isEditing && self.doneButton != nil {
            self.doneButton?.removeFromSuperview()
            self.doneButton = nil
            self.cancelButton?.removeFromSuperview()
            self.cancelButton = nil
        }
        
        for i in 0..<self.numberOfColumns {
            if let columnView = self.view(atColumn: i) as? RegisterCell {
                columnView.isEditable = self.isEditing
            }
        }
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        if self.isEmphasized {
            NSColor.selectedControlColor.setStroke()
            NSColor.selectedControlColor.withAlphaComponent(0.15).setFill()
        } else {
            NSColor(white: 0.75, alpha: 1).setStroke()
            NSColor(white: 0.95, alpha: 1).setFill()
        }
        
        let path = NSBezierPath(rect: dirtyRect)
        path.fill()
        path.stroke()
    }
    
}
