//
//  RegisterCell.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class RegisterCell: NSTableCellView {
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if backgroundStyle != oldValue {
                self.updateAppearance()
            }
        }
    }

    var text: String? {
        didSet {
            self.textLayer.string = text
        }
    }
    
    var alignment: NSTextAlignment = .left {
        didSet {
            switch alignment {
            case .left:
                self.textLayer.alignmentMode = kCAAlignmentLeft
            case .center:
                self.textLayer.alignmentMode = kCAAlignmentCenter
            case .right:
                self.textLayer.alignmentMode = kCAAlignmentRight
            case .justified:
                self.textLayer.alignmentMode = kCAAlignmentJustified
            case .natural:
                self.textLayer.alignmentMode = kCAAlignmentNatural
            }
        }
    }
    
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        
        let font = NSFont.systemFont(ofSize: 13)
        
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.anchorPoint = CGPoint(x: 0, y: 0)
        textLayer.foregroundColor = NSColor.black.cgColor
        textLayer.truncationMode = kCATruncationEnd
        textLayer.frame.size.height = NSString(string: "a").size(withAttributes: [.font: font]).height
        textLayer.actions = [
            "contents": NSNull()
        ]
        
        return textLayer
    }()
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layer?.addSublayer(self.textLayer)
    }
    
    override func layout() {
        super.layout()
        
        
        let newFrame = NSRect(
            x: 0,
            y: (self.frame.size.height - self.textLayer.frame.size.height) / 2,
            width: self.bounds.size.width,
            height: self.textLayer.frame.size.height)
        
        self.textLayer.frame = newFrame.insetBy(dx: 3, dy: 0)
    }
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        self.textLayer.contentsScale = self.window?.screen?.backingScaleFactor ?? 1
    }
    
    func updateAppearance() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if self.backgroundStyle == .dark {
            self.textLayer.foregroundColor = NSColor.white.cgColor
        } else if self.backgroundStyle == .light {
            self.textLayer.foregroundColor = NSColor.black.cgColor
        }
        
        CATransaction.commit()
    }
    
}
