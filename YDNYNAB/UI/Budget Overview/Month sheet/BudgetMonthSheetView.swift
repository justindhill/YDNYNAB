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
        
        self.summaryView.make([.left, .right, .top], equalTo: self)
        self.summaryView.make(.height, equalTo: Constant.summaryViewHeight)
        
        self.totalsView.make([.left, .right], equalTo: self)
        self.totalsView.make(.top, equalTo: .bottom, of: self.summaryView)
        self.totalsView.make(.height, equalTo: Constant.totalsViewHeight)
        
        self.detailsTableScrollView.make([.left, .right, .bottom], equalTo: self)
        self.detailsTableScrollView.make(.top, equalTo: .bottom, of: self.totalsView)
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
