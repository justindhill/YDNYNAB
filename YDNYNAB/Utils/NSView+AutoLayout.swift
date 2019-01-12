//
//  NSView+AutoLayout.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/12/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import AppKit

extension NSView {
    
    typealias Edge = NSLayoutConstraint.Attribute
    
    func makeEdgesEqual(to otherView: NSView, insetBy insets: NSEdgeInsets = .zero) {
        self.make([.top, .left, .bottom, .right], equalTo: otherView, insetBy: insets)
    }
    
    func make(_ edges: [Edge], equalTo otherView: NSView, insetBy insets: NSEdgeInsets = .zero) {
        for edge in edges {
            let constant: CGFloat
            switch edge {
            case .leading, .left:
                constant = insets.left
            case .trailing, .right:
                constant = -insets.right
            case .top:
                constant = insets.top
            case .bottom:
                constant = -insets.bottom
            case .width, .height, .centerX, .centerY, .firstBaseline, .lastBaseline, .notAnAttribute:
                constant = 0
            }
            
            self.make(edge, equalTo: edge, of: otherView, multiplier: 1, constant: constant)
        }
    }
    
    @discardableResult func make(_ edge: Edge,
                                 equalTo otherView: NSView,
                                 multiplier: CGFloat = 1,
                                 constant: CGFloat = 0) -> NSLayoutConstraint {
        return self.make(edge, equalTo: edge, of: otherView, multiplier: multiplier, constant: constant)
    }
    
    @discardableResult func make(_ edge: Edge,
                                 equalTo otherEdge: Edge,
                                 of otherView: NSView,
                                 multiplier: CGFloat = 1,
                                 constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: edge,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: otherEdge,
                                            multiplier: multiplier,
                                            constant: constant)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let commonAncestor = self.ancestorShared(with: otherView) {
            commonAncestor.addConstraint(constraint)
        } else {
            fatalError("The two specified views do not share an ancestor")
        }
        
        return constraint
    }
    
    @discardableResult func make(_ edge: Edge, equalTo constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: edge,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: constant)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(constraint)
        return constraint
    }
    
}

extension NSEdgeInsets {
    static var zero: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    static func with(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> NSEdgeInsets {
        return NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    static func equal(_ value: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
}
