//
//  BudgetMonthSheetView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetMonthSheetView: NSView {

    enum Constant {
        static let summaryViewHeight: CGFloat = 125
        static let totalsViewHeight: CGFloat = 50
    }

    let summaryView = BudgetMonthSummaryView()
    let totalsView = BudgetMonthTotalsView()
    let outlineView = YDNOutlineView()
    let detailsTableScrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self.summaryView)
        self.addSubview(self.totalsView)
        self.addSubview(self.detailsTableScrollView)
        self.detailsTableScrollView.hasVerticalScroller = true
        self.detailsTableScrollView.documentView = self.outlineView
        self.outlineView.allowsColumnResizing = false
        self.outlineView.allowsColumnReordering = false
        self.outlineView.floatsGroupRows = false
        self.outlineView.showsDisclosureIndicator = false
        
        self.summaryView.translatesAutoresizingMaskIntoConstraints = false
        self.summaryView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.summaryView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.summaryView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.summaryView.heightAnchor.constraint(equalToConstant: Constant.summaryViewHeight).isActive = true
        
        self.totalsView.translatesAutoresizingMaskIntoConstraints = false
        self.totalsView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.totalsView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.totalsView.topAnchor.constraint(equalTo: self.summaryView.bottomAnchor).isActive = true
        self.totalsView.heightAnchor.constraint(equalToConstant: Constant.totalsViewHeight).isActive = true
        
        self.detailsTableScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsTableScrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.detailsTableScrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.detailsTableScrollView.topAnchor.constraint(equalTo: self.totalsView.bottomAnchor).isActive = true
        self.detailsTableScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layout() {
        super.layout()
        let scrollerWidth: CGFloat = self.detailsTableScrollView.verticalScroller?.frame.size.width ?? 0
        let documentVisibleWidth = self.detailsTableScrollView.documentVisibleRect.size.width
        let actualVisibleWidth = documentVisibleWidth - scrollerWidth
        
        self.outlineView.tableColumns.forEach { (column) in
            column.width = actualVisibleWidth / CGFloat(self.outlineView.numberOfColumns)
        }
    }
    
}
