//
//  Account.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import RealmSwift

class Account: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
}
