//
//  RegisterRowView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/16/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol RegisterRowViewDelegate: class {
    func registerRowViewDidCommitChanges(_ rowView: RegisterRowView)
    func registerRowViewDidClickCancel(_ rowView: RegisterRowView)
}

class RegisterRowView: NSTableRowView, YDNTextFieldDelegate {
    
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
    
    private lazy var columnViews: [RegisterCell] = {
        return stride(from: 0, to: self.numberOfColumns, by: 1).compactMap { self.view(atColumn: $0) as? RegisterCell }
    }()
    
    func updateEditingState() {
        self.selectionHighlightStyle = .sourceList
        if self.isEditing && self.doneButton == nil {
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
                editingAreaBackground.left.equalTo(self)
                editingAreaBackground.right.equalTo(self)
                editingAreaBackground.top.equalTo(self).offset(1)
                editingAreaBackground.height.equalTo(Constant.collapsedHeight)
            }
            
        } else if !self.isEditing && self.doneButton != nil {
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
                columnView.inputTextField.focusDelegate = self.isEditing ? self : nil
            }
        }
        
    }
    
    override func layout() {
        super.layout()
        
        self.editingAreaBackground?.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    }
    
    func findRegisterCellContaining(view: NSView) -> (Int, RegisterCell)? {
        guard let superview = view.superview else {
            return nil
        }
        
        let columnViews = self.columnViews
        let textViewOrigin = superview.convert(view.frame.origin, to: self)
        
        let originatingColumnViewIndex = columnViews.firstIndex { (view) -> Bool in
            return view.frame.contains(textViewOrigin)
        }
        
        if let originatingColumnViewIndex = originatingColumnViewIndex {
                return (originatingColumnViewIndex, columnViews[originatingColumnViewIndex])
        }
        
        return nil
    }
    
    func findBottomCellView() -> NSView? {
        for view in self.subviews {
            if view is NSTableCellView {
                return view
            }
        }
        
        return nil
    }
    
    func textFieldDidFocus(_ textField: YDNTextField) {
        print("\(textField.stringValue) focus")
        DispatchQueue.main.async {
            textField.currentEditor()?.selectAll(self)
        }
    }
    
    func textFieldDidBlur(_ textField: YDNTextField, dueTo movement: NSTextMovement) {
        print("\(textField.stringValue) blur")
        if let originatingColumnViewIndex = self.findRegisterCellContaining(view: textField)?.0 {
            DispatchQueue.main.async {
                switch movement {
                case .tab:
                    let index = min(originatingColumnViewIndex + 1, self.columnViews.count - 1)
                    let cellView = self.columnViews[index]
                    cellView.beginEditing()
                    
                case .backtab:
                    let index = max(originatingColumnViewIndex - 1, 0)
                    let cellView = self.columnViews[index]
                    cellView.beginEditing()
                case .return:
                    self.commitChanges()
                default:
                    break
                }
            }
        }
    }
    
    @objc func commitChanges() {
        self.delegate?.registerRowViewDidCommitChanges(self)
    }
    
    @objc func cancelButtonClicked() {
        self.delegate?.registerRowViewDidClickCancel(self)
    }
    
}
