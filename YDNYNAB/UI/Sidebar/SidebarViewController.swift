//
//  SidebarViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol SidebarViewControllerDelegate: class {
    func sidebarViewController(_ sidebarViewController: SidebarViewController,
                               selectionDidChange: SidebarViewController.SelectionIdentifier)
}

class SidebarViewController: NSViewController, StackedSelectionViewDelegate {
        
    enum SelectionIdentifier {
        case budget
//        case reports
        case allTransactions
//        case account(account: Account)
    }
    
    enum Constant {
        static let contentInset: CGFloat = 20
    }
    
    weak var delegate: SidebarViewControllerDelegate?
    
    private lazy var modeSelector: StackedSelectionView = {
        let selectionView = StackedSelectionView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.delegate = self
        selectionView.items = [
            StackedSelectionView.SelectableItem(title: "Budget", selectionIdentifier: SelectionIdentifier.budget),
            StackedSelectionView.SelectableItem(title: "Reports", selectionIdentifier: SelectionIdentifier.budget),
            StackedSelectionView.SelectableItem(title: "All Accounts", selectionIdentifier: SelectionIdentifier.allTransactions)
        ]
        
        return selectionView
    }()
    
    var visualEffectView: NSVisualEffectView {
        return self.view as! NSVisualEffectView
    }
    
    override func loadView() {
        self.view = NSVisualEffectView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(modeSelector)
        self.modeSelector.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: Constant.contentInset).isActive = true
        self.modeSelector.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Constant.contentInset).isActive = true
        self.modeSelector.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -Constant.contentInset).isActive = true
        
        self.visualEffectView.material = .sidebar
    }
    
    func stackedSelectionView(_ stackedSelectionView: StackedSelectionView, selectionDidChange selection: StackedSelectionView.SelectableItem) {
        if let selectionIdentifier = selection.selectionIdentifier as? SelectionIdentifier {
            self.delegate?.sidebarViewController(self, selectionDidChange: selectionIdentifier)
        }
    }

}
