//
//  MonthBudgetCurrencyTableCellView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetCurrencyTableCellView: NSTableCellView {
    
    enum Constant {
        static let reuseIdentifier = NSUserInterfaceItemIdentifier(rawValue: "MonthBudgetCurrencyTableCellView")
    }
        
    var mouseoverCursor: NSCursor? = nil
    var underlinesTextOnMouseover: Bool = false
    
    var font: NSFont = NSFont.systemFont(ofSize: 13) {
        didSet {
            self.currencyTextLayer.font = font
            self.currencyTextLayer.fontSize = font.pointSize
        }
    }
    
    var text: String? {
        didSet {
            self.currencyTextLayer.string = text
        }
    }
    
    var alignment: NSTextAlignment = .left {
        didSet {
            switch alignment {
            case .left:
                self.currencyTextLayer.alignmentMode = kCAAlignmentLeft
            case .center:
                self.currencyTextLayer.alignmentMode = kCAAlignmentCenter
            case .right:
                self.currencyTextLayer.alignmentMode = kCAAlignmentRight
            case .justified:
                self.currencyTextLayer.alignmentMode = kCAAlignmentJustified
            case .natural:
                self.currencyTextLayer.alignmentMode = kCAAlignmentNatural
            }
        }
    }
    
    private lazy var currencyTextLayer: CATextLayer = {
        let layer = CATextLayer()
        
        let font = NSFont.systemFont(ofSize: 13)
        layer.font = font
        layer.fontSize = font.pointSize
        layer.foregroundColor = NSColor.black.cgColor
        layer.truncationMode = kCATruncationEnd
        layer.frame.size.height = NSString(string: "a").size(withAttributes: [.font: font]).height
        layer.anchorPoint = .zero
        layer.actions = [
            "contents": NSNull()
        ]
        
        return layer
    }()
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.identifier = Constant.reuseIdentifier
        
        self.layer?.addSublayer(self.currencyTextLayer)
    }
    
    override func layout() {
        super.layout()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let newTextLayerFrame = NSRect(
            x: 0,
            y: (self.frame.size.height - self.currencyTextLayer.frame.size.height) / 2,
            width: self.frame.size.width,
            height: self.currencyTextLayer.frame.size.height)
        self.currencyTextLayer.frame = newTextLayerFrame.insetBy(dx: 3, dy: 0)
        CATransaction.commit()
    }
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        self.currencyTextLayer.contentsScale = self.window?.screen?.backingScaleFactor ?? 1
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.mouseoverCursor?.set()
        
        if let text = self.text, self.underlinesTextOnMouseover {
            self.currencyTextLayer.string = NSAttributedString(
                string: text,
                attributes: [
                    .font: self.font,
                    .foregroundColor: NSColor.black,
                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                    .underlineColor: NSColor.black
                ]
            )
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
        
        if self.underlinesTextOnMouseover {
            self.currencyTextLayer.string = self.text
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.tracksMouseMovement = true
    }

}
