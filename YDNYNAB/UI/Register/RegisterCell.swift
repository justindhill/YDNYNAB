//
//  RegisterCell.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/15/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol RegisterCellDelegate: class {
    func registerCellDidClickDisclosureIndicator(_ cell: RegisterCell)
}

class RegisterCell: NSTableCellView {
    
    enum ExpansionState {
        case none
        case collapsed
        case expanded
        
        fileprivate var disclosureTransform: CATransform3D {
            switch self {
            case .none, .collapsed:
                return CATransform3DIdentity
            case .expanded:
                return CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 2))
            }
        }
        
        fileprivate var rotationAngle: CGFloat {
            switch self {
            case .none, .collapsed:
                return 0
            case .expanded:
                return 90
            }
        }
    }
    
    enum Constant {
        static let collapsedHeight: CGFloat = RegisterRowView.Constant.collapsedHeight
        static let expandedHeight: CGFloat = RegisterRowView.Constant.expandedHeight
    }
    
    weak var delegate: RegisterCellDelegate?
    var columnIdentifier: RegisterViewController.ColumnIdentifier?
    
    var isEditable: Bool = false {
        didSet {
            self.inputTextField.ydn_isEditable = self.isEditable
            self.needsLayout = true
        }
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    var expansionState: ExpansionState = .none {
        didSet { self.needsLayout = true }
    }
    
    private let font = NSFont.systemFont(ofSize: 13)
    
    private let disclosureIndicatorView: NSImageView = NSImageView(image: #imageLiteral(resourceName: "disclosure-caret"))
    
    private(set) lazy var inputTextField: YDNTextField = {
        let textField = YDNTextField()
        textField.isBordered = false
        textField.isBezeled = false
        textField.textColor = Theme.Color.text
        textField.backgroundColor = NSColor.clear
        textField.font = self.font
        textField.alignment = self.alignment
        textField.cell?.truncatesLastVisibleLine = true
        textField.cell?.lineBreakMode = .byTruncatingTail
        textField.focusRingType = .none
        textField.forwardMovements = [.tab]
        textField.ydn_isEditable = false
        
        return textField
    }()

    var text: String? {
        didSet {
            if let text = text {
                self.inputTextField.stringValue = text
            }
            
            self.toolTip = text
        }
    }
    
    var alignment: NSTextAlignment = .left {
        didSet {
            switch alignment {
            case .left:
                self.inputTextField.alignment = .left
            case .center:
                self.inputTextField.alignment = .center
            case .right:
                self.inputTextField.alignment = .right
            case .justified:
                self.inputTextField.alignment = .justified
            case .natural:
                self.inputTextField.alignment = .natural
            @unknown default:
                fatalError()
            }
        }
    }
    
    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let disclosureClick = NSClickGestureRecognizer(target: self, action: #selector(disclosureIndicatorClicked))
        self.disclosureIndicatorView.addGestureRecognizer(disclosureClick)
        
        self.addSubview(self.inputTextField)
        self.addSubview(self.disclosureIndicatorView)
        self.wantsLayer = true
    }
    
    override func layout() {
        super.layout()
        
        self.inputTextField.textColor = Theme.Color.text
        let lineHeight = ceil(self.font.ascender + abs(self.font.descender) + self.font.leading)
        
        self.disclosureIndicatorView.isHidden = (self.expansionState == .none)
        
        var disclosureOffset: CGFloat = 0
        if !self.disclosureIndicatorView.isHidden {
            disclosureOffset = self.disclosureIndicatorView.image?.size.width ?? 0
            
            self.disclosureIndicatorView.frame = CGRect(
                origin: CGPoint(x: 0, y: (Constant.collapsedHeight - disclosureOffset) / 2),
                size: CGSize(width: disclosureOffset, height: disclosureOffset))
            
            if let layer = self.disclosureIndicatorView.layer {
                layer.position = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
                layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

 
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    layer.transform = self.expansionState.disclosureTransform
                }
                
                let animation = CABasicAnimation(keyPath: "transform")
                animation.duration = 0.2
                animation.toValue = self.expansionState.disclosureTransform
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                layer.add(animation, forKey: nil)
                
                CATransaction.commit()
            }
        }

        var newFrame = NSRect(
            x: 0,
            y: ceil((Constant.collapsedHeight - lineHeight) / 2),
            width: self.bounds.size.width,
            height: lineHeight)
        newFrame = newFrame.insetBy(dx: 3, dy: 0)
        newFrame.origin.x += disclosureOffset
        newFrame.size.width -= disclosureOffset
        
        self.inputTextField.frame = newFrame
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        self.addCursorRect(self.disclosureIndicatorView.frame, cursor: .pointingHand)
    }
    
    func updateAppearance() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if self.backgroundStyle == .dark {
            self.inputTextField.textColor = NSColor.white
            self.disclosureIndicatorView.contentTintColor = NSColor.white
        } else if self.backgroundStyle == .light {
            self.inputTextField.textColor = Theme.Color.text
            self.disclosureIndicatorView.contentTintColor = Theme.Color.text
        }
        
        CATransaction.commit()
    }
    
    @objc func disclosureIndicatorClicked() {
        self.delegate?.registerCellDidClickDisclosureIndicator(self)
    }
    
}
