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
        
        self.summaryView.snp.makeConstraints { (summaryView) in
            summaryView.left.equalTo(self)
            summaryView.right.equalTo(self)
            summaryView.top.equalTo(self)
            summaryView.height.equalTo(Constant.summaryViewHeight)
        }
        
        self.totalsView.snp.makeConstraints { (totalsView) in
            totalsView.left.equalTo(self)
            totalsView.right.equalTo(self)
            totalsView.top.equalTo(self.summaryView.snp.bottom)
            totalsView.height.equalTo(Constant.totalsViewHeight)
        }
        
        self.detailsTableScrollView.snp.makeConstraints { (detailsTableScrollView) in
            detailsTableScrollView.left.equalTo(self)
            detailsTableScrollView.right.equalTo(self)
            detailsTableScrollView.top.equalTo(self.totalsView.snp.bottom)
            detailsTableScrollView.bottom.equalTo(self)
        }
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
