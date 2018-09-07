//
//  SidebarViewController.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/1/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa
import SnapKit

class SidebarViewController: NSViewController {
    
    enum Constant {
        static let contentInset: CGFloat = 20
    }
    
    lazy var modeSelector: StackedSelectionView = {
        let selectionView = StackedSelectionView()
        selectionView.items = [
            StackedSelectionView.SelectableItem(title: "Budget"),
            StackedSelectionView.SelectableItem(title: "Reports"),
            StackedSelectionView.SelectableItem(title: "All Accounts")
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

}
