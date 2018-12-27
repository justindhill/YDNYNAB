//
//  SidebarViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import SnapKit

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
        self.modeSelector.snp.makeConstraints {
            $0.leading.equalTo(self.view).inset(Constant.contentInset)
            $0.top.equalTo(self.view).inset(Constant.contentInset)
            $0.right.equalTo(self.view).inset(Constant.contentInset)
        }
        
        self.visualEffectView.material = .sidebar
    }
    
    func stackedSelectionView(_ stackedSelectionView: StackedSelectionView, selectionDidChange selection: StackedSelectionView.SelectableItem) {
        if let selectionIdentifier = selection.selectionIdentifier as? SelectionIdentifier {
            self.delegate?.sidebarViewController(self, selectionDidChange: selectionIdentifier)
        }
    }

}