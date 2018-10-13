//
//  Hoverable.swift
//  YDNYNAB
//
//  Created by Justin Hill on 10/13/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import Cocoa

protocol Hoverable: class {
    func enterHoverState()
    func leaveHoverState()
}
