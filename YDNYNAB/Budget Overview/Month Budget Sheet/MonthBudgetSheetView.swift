//
//  MonthBudgetSheetView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSheetView: NSView {

    let summaryView = MonthBudgetSummaryView()
    let totalsView = MonthBudgetTotalsView()
    let detailsTableView = NSTableView()
    let detailsTableScrollView = NSScrollView()
    
    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(self.summaryView)
        self.addSubview(self.totalsView)
        self.addSubview(self.detailsTableScrollView)
        self.detailsTableScrollView.hasVerticalScroller = true
        self.detailsTableScrollView.documentView = self.detailsTableView
        self.detailsTableScrollView.postsBoundsChangedNotifications = true
        self.detailsTableView.allowsColumnResizing = false
        self.detailsTableView.allowsColumnReordering = false
        
        self.summaryView.snp.makeConstraints { (summaryView) in
            summaryView.left.equalTo(self).offset(10)
            summaryView.right.equalTo(self).offset(-10)
            summaryView.top.equalTo(self).offset(10)
            summaryView.height.equalTo(125)
        }
        
        self.totalsView.snp.makeConstraints { (totalsView) in
            totalsView.left.equalTo(self).offset(10)
            totalsView.right.equalTo(self).offset(-10)
            totalsView.top.equalTo(self.summaryView.snp.bottom).offset(10)
            totalsView.height.equalTo(50)
        }
        
        self.detailsTableScrollView.snp.makeConstraints { (detailsTableScrollView) in
            detailsTableScrollView.left.equalTo(self).offset(10)
            detailsTableScrollView.right.equalTo(self).offset(-10)
            detailsTableScrollView.top.equalTo(self.totalsView.snp.bottom).offset(10)
            detailsTableScrollView.bottom.equalTo(self).offset(-10)
        }
    }
    
    override func layout() {
        super.layout()
        let scrollerWidth: CGFloat = self.detailsTableScrollView.verticalScroller?.frame.size.width ?? 0
        let documentVisibleWidth = self.detailsTableScrollView.documentVisibleRect.size.width
        let actualVisibleWidth = documentVisibleWidth - scrollerWidth
        
        self.detailsTableView.tableColumns.forEach { (column) in
            column.width = actualVisibleWidth / CGFloat(self.detailsTableView.numberOfColumns)
        }
    }
    
}
