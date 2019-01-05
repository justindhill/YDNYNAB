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

class RegisterRowView: NSTableRowView, YDNTextFieldDelegate, YDNTextFieldKeyViewProvider {
    
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
            
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.bottomAnchor.constraint(equalTo: self.topAnchor, constant: (Constant.expandedHeight - Constant.buttonPadding)).isActive = true
            cancelButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
            
            doneButton.translatesAutoresizingMaskIntoConstraints = false
            doneButton.bottomAnchor.constraint(equalTo: self.topAnchor, constant: (Constant.expandedHeight - Constant.buttonPadding)).isActive = true
            doneButton.rightAnchor.constraint(equalTo: cancelButton.leftAnchor, constant: Constant.buttonPadding).isActive = true
            
            editingAreaBackground.translatesAutoresizingMaskIntoConstraints = false
            editingAreaBackground.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            editingAreaBackground.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            editingAreaBackground.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            editingAreaBackground.heightAnchor.constraint(equalToConstant: Constant.collapsedHeight).isActive = true
            
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
                columnView.inputTextField.keyViewProvider = self.isEditing ? self : nil
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
//        print("\(textField.stringValue) focus")
//        DispatchQueue.main.async {
//            textField.currentEditor()?.selectAll(self)
//        }
    }
    
    func textFieldDidBlur(_ textField: YDNTextField, commit: Bool) {
//        print("\(textField.stringValue) blur - commit: \(commit)")

    }
    
    func nextKeyView(for textField: YDNTextField) -> YDNTextField? {
        if let originatingColumnViewIndex = self.findRegisterCellContaining(view: textField)?.0 {
            let index = min(originatingColumnViewIndex + 1, self.columnViews.count - 1)
            let cellView = self.columnViews[index]
            return cellView.inputTextField
        }
        
        return nil
    }
    
    func previousKeyView(for textField: YDNTextField) -> YDNTextField? {
        if let originatingColumnViewIndex = self.findRegisterCellContaining(view: textField)?.0 {
            let index = max(originatingColumnViewIndex - 1, 0)
            let cellView = self.columnViews[index]
            return cellView.inputTextField
        }
        
        return nil
    }
    
    @objc func commitChanges() {
        self.delegate?.registerRowViewDidCommitChanges(self)
    }
    
    @objc func cancelButtonClicked() {
        self.delegate?.registerRowViewDidClickCancel(self)
    }
    
}
