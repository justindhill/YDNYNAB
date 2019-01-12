//
//  BudgetMonthSummaryView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class BudgetMonthSummaryView: NSView {
    
    private enum Constant {
        static let dateStackWidth: CGFloat = 60
        static let padding: CGFloat = 10
    }
    
    let monthLabel: NSTextField = {
        let label = NSTextField(labelWithString: "JAN")
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        
        return label
    }()
    
    let yearLabel: NSTextField = {
        let label = NSTextField(labelWithString: "2018")
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        
        return label
    }()
    
    lazy var dateStackView: NSStackView = {
        let stackView = NSStackView(views: [self.monthLabel, self.yearLabel])
        stackView.orientation = .vertical
        
        return stackView
    }()
    
    let dateSeparator: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme.Color.text.withAlphaComponent(0.75).cgColor
        return view
    }()

    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        self.layer?.borderColor = Theme.Color.text.withAlphaComponent(0.75).cgColor
        self.layer?.borderWidth = 1
        
        self.addSubview(self.dateStackView)
        self.dateStackView.make([.left, .top], equalTo: self, insetBy: .equal(Constant.padding))
        
        self.addSubview(self.dateSeparator)
        self.dateSeparator.make(.width, equalTo: 1)
        self.dateSeparator.make(.left, equalTo: .right, of: self.dateStackView, constant: Constant.padding)
        self.dateSeparator.make([.top, .bottom], equalTo: self)
    }
    
    func updateForMonth(month: MonthYear) {
        self.monthLabel.stringValue = DateUtils.threeLetterAbbreviation(forMonth: month.month)
        self.yearLabel.stringValue = "\(month.year)"
    }
    
}
