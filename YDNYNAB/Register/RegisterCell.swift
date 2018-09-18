//
//  RegisterCell.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterCell: NSTableCellView {
    
    enum Constant {
        static let collapsedHeight: CGFloat = RegisterRowView.Constant.collapsedHeight
        static let expandedHeight: CGFloat = RegisterRowView.Constant.expandedHeight
    }
    
//    override var backgroundStyle: NSView.BackgroundStyle {
//        didSet {
//            if backgroundStyle != oldValue {
//                self.updateAppearance()
//            }
//        }
//    }
    
    var isEditable: Bool = false {
        didSet {
            self.needsLayout = true
        }
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    private let font = NSFont.systemFont(ofSize: 13)
    
    private var inputTextField: NSTextField? = nil

    var text: String? {
        didSet {
            if self.isEditable {
                if let text = text {
                    self.inputTextField?.stringValue = text
                }
            } else {
                self.textLayer.string = text
            }
        }
    }
    
    var alignment: NSTextAlignment = .left {
        didSet {
            switch alignment {
            case .left:
                self.textLayer.alignmentMode = .left
            case .center:
                self.textLayer.alignmentMode = .center
            case .right:
                self.textLayer.alignmentMode = .right
            case .justified:
                self.textLayer.alignmentMode = .justified
            case .natural:
                self.textLayer.alignmentMode = .natural
            }
        }
    }
    
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        
        textLayer.font = self.font
        textLayer.fontSize = font.pointSize
        textLayer.anchorPoint = CGPoint(x: 0, y: 0)
        textLayer.truncationMode = .end
        textLayer.frame.size.height = NSString(string: "a").size(withAttributes: [.font: font]).height
        textLayer.actions = [
            "contents": NSNull(),
            "hidden": NSNull()
        ]
        
        return textLayer
    }()
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layer?.isGeometryFlipped = true
        self.layer?.addSublayer(self.textLayer)
    }
    
    override func layout() {
        super.layout()
        
        self.inputTextField?.textColor = Theme.Color.text
        self.textLayer.foregroundColor = Theme.Color.text.cgColor
        
        var newFrame = NSRect(
            x: 0,
            y: (Constant.collapsedHeight - self.textLayer.frame.size.height) / 2,
            width: self.bounds.size.width,
            height: self.textLayer.frame.size.height)
        newFrame = newFrame.insetBy(dx: 3, dy: 0)
        
        if self.isEditable {
            let inputTextField: NSTextField
            if let existingTextField = self.inputTextField {
                inputTextField = existingTextField
            } else {
                inputTextField = self.configureNewTextField()
                self.inputTextField = inputTextField
                self.addSubview(inputTextField)
            }
            
            if let text = self.text {
                inputTextField.stringValue = text
            }
            
            self.textLayer.isHidden = true
            inputTextField.frame = newFrame
        } else {
            self.inputTextField?.removeFromSuperview()
            self.inputTextField = nil
            self.textLayer.isHidden = false
            self.textLayer.frame = newFrame
        }

    }
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        self.textLayer.contentsScale = self.window?.screen?.backingScaleFactor ?? 1
    }
    
    func beginEditing() {
        self.window?.makeFirstResponder(self.inputTextField)
    }
    
    func updateAppearance() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if self.backgroundStyle == .dark {
            self.textLayer.foregroundColor = NSColor.white.cgColor
        } else if self.backgroundStyle == .light {
            self.textLayer.foregroundColor = Theme.Color.text.cgColor
        }
        
        CATransaction.commit()
    }
    
    func configureNewTextField() -> NSTextField {
        let textField = NSTextField()
        textField.isBordered = false
        textField.isBezeled = false
        textField.textColor = Theme.Color.text
        textField.backgroundColor = NSColor.textBackgroundColor
        textField.font = self.font
        textField.alignment = self.alignment
        textField.cell?.truncatesLastVisibleLine = true
        textField.cell?.lineBreakMode = .byTruncatingTail
        
        return textField
    }
    
}
