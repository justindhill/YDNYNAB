//
//  MonthBudgetSummaryView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetSummaryView: NSView {
    
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
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor
        return view
    }()

    required init?(coder decoder: NSCoder) { fatalError("Not implemented") }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        self.layer?.borderColor = NSColor.black.withAlphaComponent(0.75).cgColor
        self.layer?.borderWidth = 1
        
        self.addSubview(self.dateStackView)
        self.dateStackView.snp.makeConstraints { (dateStackView) in
            dateStackView.left.equalTo(self).offset(Constant.padding)
            dateStackView.top.equalTo(self).offset(Constant.padding)
        }
        
        self.addSubview(self.dateSeparator)
        self.dateSeparator.snp.makeConstraints { (dateSeparator) in
            dateSeparator.width.equalTo(1)
            dateSeparator.left.equalTo(self.dateStackView.snp.right).offset(Constant.padding)
            dateSeparator.top.equalTo(self)
            dateSeparator.bottom.equalTo(self)
        }
    }
    
}
