//
//  MonthBudgetTableRowView.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/6/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

class MonthBudgetTableRowView: NSTableRowView {
    
    private enum Constant {
        static let rowNumberKey = "MonthBudgetTableRowViewRowNumberKey"
    }
    
    let row: Int

    required init?(coder decoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(row: Int) {
        self.row = row
        super.init(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMouseEnteredNotification(_:)), name: .monthBudgetTableRowViewMouseEntered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMouseExitedNotification(_:)), name: .monthBudgetTableRowViewMouseExited, object: nil)
    }
    
    override func updateTrackingAreas() {
        self.tracksMouseMovement = true
    }
    
    override func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(Notification(name: .monthBudgetTableRowViewMouseEntered, object: nil, userInfo: [Constant.rowNumberKey: self.row]))
    }
    
    override func mouseExited(with event: NSEvent) {
        NotificationCenter.default.post(Notification(name: .monthBudgetTableRowViewMouseExited, object: nil, userInfo: [Constant.rowNumberKey: self.row]))
    }
    
    @objc private func didReceiveMouseEnteredNotification(_ note: Notification) {
        if let row = note.userInfo?[Constant.rowNumberKey] as? Int, row == self.row {
            self.backgroundColor = Theme.Color.rowBackgroundHoverColor
        }

    }
    
    @objc private func didReceiveMouseExitedNotification(_ note: Notification) {
        if let row = note.userInfo?[Constant.rowNumberKey] as? Int, row == self.row {
            self.backgroundColor = .clear
        }
    }

}

fileprivate extension Notification.Name {
    static let monthBudgetTableRowViewMouseEntered = Notification.Name(rawValue: "monthBudgetTableRowViewMouseEnteredNotification")
    static let monthBudgetTableRowViewMouseExited = Notification.Name(rawValue: "monthBudgetTableRowViewMouseExitedNotification")
}
