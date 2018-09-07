//
//  StackedSelectionView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/2/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class StackedSelectionView: NSView {
    
    enum Constant {
        static let itemSelectedColor = NSColor.black
        static let itemHighlightedColor = Constant.itemSelectedColor.withAlphaComponent(0.35)
        static let itemLeadingTextOffset: CGFloat = 40
    }
    
    typealias Item = NSView
    class SelectableItem: Item {
        let titleLabel = NSTextField(labelWithString: "")
        let title: String
        
        required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
        init(title: String) {
            self.title = title
            super.init(frame: .zero)
            
            self.titleLabel.stringValue = title
            
            self.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints {
                $0.edges.equalTo(self).inset(5)
            }
        }
    }
    
    lazy var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.wantsLayer = true
        stackView.orientation = .vertical
        stackView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.15).cgColor
        stackView.layer?.cornerRadius = 5
        
        return stackView
    }()
    var items: [Item] = [] {
        didSet { self.updateItems() }
    }
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self.stackView)
        
        self.stackView.snp.makeConstraints { $0.edges.equalTo(self) }
        self.updateItems()
    }
    
    func updateItems() {
        self.stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        self.items.forEach { item in
            self.stackView.addArrangedSubview(item)
            item.snp.makeConstraints { $0.width.equalTo(self.stackView) }
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.updateHoverState(with: event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.updateHoverState(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.updateHoverState(with: event)
    }
    
    func updateHoverState(with event: NSEvent) {
        self.items.forEach { item in
            let mouseLocation = self.convert(event.locationInWindow, from: nil)
            let mouseInItem = item.frame.contains(mouseLocation)
            item.layer?.backgroundColor = (mouseInItem ? Constant.itemHighlightedColor : NSColor.clear).cgColor
            
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.trackingAreas.forEach { self.removeTrackingArea($0) }
        self.addTrackingArea(
            NSTrackingArea(
                rect: self.bounds,
                options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved],
                owner: self,
                userInfo: nil
            )
        )
    }
    
}
