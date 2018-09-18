//
//  RegisterRowView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol RegisterRowViewDelegate: class {
    func registerRowViewDidClickDone(_ rowView: RegisterRowView)
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView)
}

class RegisterRowView: NSTableRowView {
    
    private var doneButton: NSButton?
    private var cancelButton: NSButton?
    private var editingAreaBackground: NSView?
    
    weak var delegate: RegisterRowViewDelegate?
    
    var isEditing: Bool = false {
        didSet { self.updateEditingState() }
    }

    enum Constant {
        static let buttonPadding: CGFloat = 4
        static let collapsedHeight: CGFloat = 25
        static let expandedHeight: CGFloat = 56
    }
    
    private var columnViews: [NSView] {
        return stride(from: 0, to: self.numberOfColumns, by: 1).compactMap { self.view(atColumn: $0) as? NSView }
    }
    
    func updateEditingState() {
        self.selectionHighlightStyle = .sourceList
        if self.isEditing && self.doneButton == nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(textFieldDidEndEditing(_:)),
                                                   name: NSControl.textDidEndEditingNotification,
                                                   object: nil)
            
            let doneButton = NSButton(title: "Done", target: self, action: #selector(commitChanges))
            self.doneButton = doneButton
            
            let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelButtonClicked))
            self.cancelButton = cancelButton
            
            let editingAreaBackground = NSView()
            editingAreaBackground.wantsLayer = true
            self.editingAreaBackground = editingAreaBackground
            
            self.addSubview(doneButton)
            self.addSubview(cancelButton)
            self.addSubview(editingAreaBackground, positioned: .below, relativeTo: self.findBottomCellView())
            
            cancelButton.snp.makeConstraints { cancelButton in
                cancelButton.bottom.equalTo(self.snp.top).offset(Constant.expandedHeight - Constant.buttonPadding)
                cancelButton.right.equalTo(self).offset(-4)
            }
            
            doneButton.snp.makeConstraints { doneButton in
                doneButton.bottom.equalTo(self.snp.top).offset(Constant.expandedHeight - Constant.buttonPadding)
                doneButton.right.equalTo(cancelButton.snp.left).offset(-Constant.buttonPadding)
            }
            
            editingAreaBackground.snp.makeConstraints { editingAreaBackground in
                editingAreaBackground.left.equalTo(self).offset(1)
                editingAreaBackground.right.equalTo(self).offset(-1)
                editingAreaBackground.top.equalTo(self).offset(1)
                editingAreaBackground.height.equalTo(Constant.collapsedHeight)
            }
            
        } else if !self.isEditing && self.doneButton != nil {
            NotificationCenter.default.removeObserver(self)
            
            self.doneButton?.removeFromSuperview()
            self.doneButton = nil
            self.cancelButton?.removeFromSuperview()
            self.cancelButton = nil
            self.editingAreaBackground?.removeFromSuperview()
            self.editingAreaBackground = nil
        }
        
        for i in 0..<self.numberOfColumns {
            if let columnView = self.view(atColumn: i) as? RegisterCell {
                columnView.isEditable = self.isEditing
            }
        }
    }
    
    override func layout() {
        super.layout()
        
        self.editingAreaBackground?.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    }
    
    func findBottomCellView() -> NSView? {
        for view in self.subviews {
            if view is NSTableCellView {
                return view
            }
        }
        
        return nil
    }
    
    @objc private func textFieldDidEndEditing(_ notification: Notification) {
        guard let textView = notification.userInfo?["NSFieldEditor"] as? NSView,
            let textViewSuperview = textView.superview,
            let textMovementRawValue = notification.userInfo?["NSTextMovement"] as? Int,
            let textMovement = NSTextMovement(rawValue: textMovementRawValue) else {
                return
        }
        
        let columnViews = self.columnViews
        let textViewOrigin = textViewSuperview.convert(textView.frame.origin, to: self)
        
        let originatingColumnViewIndex = columnViews.firstIndex { (view) -> Bool in
            return view.frame.contains(textViewOrigin)
        }
        
        if let originatingColumnViewIndex = originatingColumnViewIndex {
            DispatchQueue.main.async {
                switch textMovement {
                case .tab:
                    let index = min(originatingColumnViewIndex + 1, columnViews.count - 1)
                    let cellView = columnViews[index] as? RegisterCell
                    cellView?.beginEditing()
                    
                case .backtab:
                    let index = max(originatingColumnViewIndex - 1, 0)
                    let cellView = columnViews[index] as? RegisterCell
                    cellView?.beginEditing()
                case .return:
                    self.commitChanges()
                default:
                    break
                }
            }
        }
    }
    
    @objc func commitChanges() {
        self.delegate?.registerRowViewDidClickDone(self)
    }
    
    @objc func cancelButtonClicked() {
        self.delegate?.registerRowViewDidClickCancel(self)
    }
    
}
