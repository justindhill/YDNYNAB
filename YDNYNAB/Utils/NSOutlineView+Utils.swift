//
//  NSOutlineView+Utils.swift
//  YDNYNAB
//
//  Created by Justin Hill on 5/25/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import Cocoa

extension NSOutlineView {
    func rowView(forItem item: Any, makeIfNecessary: Bool) -> NSTableRowView? {
        return self.rowView(atRow: self.row(forItem: item), makeIfNecessary: makeIfNecessary)
    }
}
