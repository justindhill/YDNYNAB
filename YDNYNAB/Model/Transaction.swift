//
//  Transaction.swift
//  YDNYNAB
//
//  Created by Justin Hill on 9/7/18.
//  Copyright © 2018 Justin Hill. All rights reserved.
//

import GRDB

class Transaction: NSObject, Codable, FetchableRecord, PersistableRecord {
    
    enum FlagColor: String, Codable {
        case red
        case orange
        case yellow
        case green
        case blue
        case purple
    }

    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    /**
     The database id of the transaction, not to be confused with the unique transaction id assigned by an institution,
     which is not currently represented in this object.
     */
    var id: Int64?
    
    /**
     The id of the account that the transaction belongs to.
     */
    var account: Int64?
    
    /**
     The flag color associated with the transaction.
     */
    var flag: FlagColor?
    
    /**
     The check number associated with the transaction.
     */
    var checkNumber: String?
    
    /**
     The transaction date.
     */
    var date: Date = Date()
    
    /**
     The date used for this transaction when computing the budget. This can differ from `date` in cases like when the
     user has chosen that an income transaction should be applied to the next month's budget instead of the current one.
     */
    var effectiveDate: Date = Date()
    
    /**
     The payee associated with the transaction. Can be nil in the case of a split.
     */
    var payee: Int64?
    
    /**
     The transaction's master category.
     */
    var masterCategory: Int64?
    
    /**
     The transaction's subcategory.
     */
    var subCategory: Int64?
    
    /**
     If this transaction is a slice of a split, the id of the split transaction. Nil otherwise.
    */
    var splitParent: Int64?
    
    /**
     The memo associated with this transaction.
     */
    var memo: String?
    
    /**
     The amount of money flowing out of the account as a result of this transaction.
     */
    var outflow: Double?
    
    /**
     The amount of money flowing into the account as a result of this transaction.
     */
    var inflow: Double?
    
    /**
     Whether or not the transaction has been marked as cleared. For imported transactions, this is automatically marked
     **true**.
     */
    var cleared: Bool = false
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["account"] = account
        container["flag"] = flag
        container["checkNumber"] = checkNumber
        container["date"] = date
        container["effectiveDate"] = effectiveDate
        container["payee"] = payee
        container["masterCategory"] = masterCategory
        container["subCategory"] = subCategory
        container["memo"] = memo
        container["outflow"] = outflow
        container["inflow"] = inflow
        container["cleared"] = cleared
        container["splitParent"] = splitParent
    }
    
    // from joins, not encoded
    private(set) var accountDisplayName: String?
    private(set) var payeeDisplayName: String?
    private(set) var categoryDisplayName: String?
    
    var isSplitParent: Bool {
        get { return self.masterCategory == YDNDatabase.SplitCategoryId }
    }
}

extension Transaction.FlagColor: DatabaseValueConvertible {}
