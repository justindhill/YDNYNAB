//
//  OFXStatement.m
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import "OFXStatement.h"
#import "libofx/libofx.h"

@interface OFXStatement ()

@property (nonnull, strong) NSArray<OFXTransaction *> *transactions;

@end

@implementation OFXStatement

- (instancetype)initWithStatementData:(struct OfxStatementData)statementData {
    if (self = [self init]) {
        _currency = [NSString stringWithUTF8String:statementData.currency];
        _accountId = [NSString stringWithUTF8String:statementData.account_id];
        _ledgerBalance = statementData.ledger_balance;
        _ledgerBalanceDate = [NSDate dateWithTimeIntervalSince1970:statementData.ledger_balance_date];
        _availableBalance = statementData.available_balance;
        _beginDate = [NSDate dateWithTimeIntervalSince1970:statementData.date_start];
        _endDate = [NSDate dateWithTimeIntervalSince1970:statementData.date_end];
        
        _transactions = @[];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OFXStatement: %p> %@, %@, %@", self, self.accountId, self.beginDate, self.endDate];
}

@end
