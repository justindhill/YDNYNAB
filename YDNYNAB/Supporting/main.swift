//
//  main.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/4/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import AppKit

MenuBar.shared.populate()
NSApplication.shared.mainMenu = MenuBar.shared.rootMenu

let appDelegate = AppDelegate()

NSApplication.shared.delegate = appDelegate
NSApplication.shared.run()
