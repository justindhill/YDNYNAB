//
//  StackedSelectionView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/2/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol StackedSelectionViewDelegate: class {
    func stackedSelectionView(_ stackedSelectionView: StackedSelectionView, selectionDidChange: StackedSelectionView.SelectableItem)
}

class StackedSelectionView: NSView {
    
    enum Constant {
        static let itemLeadingTextOffset: CGFloat = 40
    }
    
    weak var delegate: StackedSelectionViewDelegate?
    var selectedIndex: Int = 0
    
    typealias Item = NSView
    class SelectableItem: Item {
        let titleLabel = NSTextField(labelWithString: "")
        let title: String
        var selectionIdentifier: Any
        
        required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
        init(title: String, selectionIdentifier: Any) {
            self.title = title
            self.selectionIdentifier = selectionIdentifier
            super.init(frame: .zero)
            
            self.titleLabel.stringValue = title
            
            self.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints {
                $0.edges.equalTo(self).inset(5)
            }
        }
        
        override func layout() {
            super.layout()
            self.titleLabel.textColor = Theme.Color.text
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
            if item.gestureRecognizers.count == 0 {
                item.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(itemWasClicked(_:))))
            }
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
            item.layer?.backgroundColor = (mouseInItem ? Theme.Color.rowBackgroundHoverColor : NSColor.clear).cgColor
            
        }
    }
    
    @objc private func itemWasClicked(_ gestureRecognizer: NSClickGestureRecognizer) {
        if let clickedItem = gestureRecognizer.view as? SelectableItem {
            self.delegate?.stackedSelectionView(self, selectionDidChange: clickedItem)
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
