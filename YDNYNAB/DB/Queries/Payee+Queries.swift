//
//  Payee+Queries.swift
//  YDNYNAB
//
//  Created by Justin Hill on 1/5/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

import GRDB

extension Payee {
    
    class func payee(withName name: String, inDb db: Database) throws -> Payee? {
        return try Payee
            .filter(sql: "name = ?", arguments: StatementArguments([name]))
            .fetchOne(db)
    }
    
}
