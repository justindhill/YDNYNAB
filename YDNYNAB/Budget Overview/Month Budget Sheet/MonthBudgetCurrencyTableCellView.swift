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
                self.currencyTextLayer.alignmentMode = .left
            case .center:
                self.currencyTextLayer.alignmentMode = .center
            case .right:
                self.currencyTextLayer.alignmentMode = .right
            case .justified:
                self.currencyTextLayer.alignmentMode = .justified
            case .natural:
                self.currencyTextLayer.alignmentMode = .natural
            }
        }
    }
    
    private lazy var currencyTextLayer: CATextLayer = {
        let layer = CATextLayer()
        
        let font = NSFont.systemFont(ofSize: 13)
        layer.font = font
        layer.fontSize = font.pointSize
        layer.truncationMode = .end
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
        
        self.currencyTextLayer.foregroundColor = Theme.Color.text.cgColor
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let newTextLayerFrame = NSRect(
            x: 0,
            y: ceil((self.frame.size.height - self.currencyTextLayer.frame.size.height) / 2),
            width: self.frame.size.width,
            height: self.currencyTextLayer.frame.size.height)
        self.currencyTextLayer.frame = newTextLayerFrame.insetBy(dx: 3, dy: 0)
        CATransaction.commit()
    }
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        self.currencyTextLayer.contentsScale = self.window?.screen?.backingScaleFactor ?? 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.underlinesTextOnMouseover = false
        self.mouseoverCursor = nil
        self.text = nil
    }

}

extension MonthBudgetCurrencyTableCellView: Hoverable {
    
    func enterHoverState() {
        self.mouseoverCursor?.set()
        
        if let text = self.text, self.underlinesTextOnMouseover {
            self.currencyTextLayer.string = NSAttributedString(
                string: text,
                attributes: [
                    .font: self.font,
                    .foregroundColor: Theme.Color.text,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: Theme.Color.text
                ]
            )
        }
    }
    
    func leaveHoverState() {
        NSCursor.arrow.set()
        
        if self.underlinesTextOnMouseover {
            self.currencyTextLayer.string = self.text
        }
    }
}
