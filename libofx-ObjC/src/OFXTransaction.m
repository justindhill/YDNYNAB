//
//  OFXTransaction.m
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import "OFXTransaction.h"
#import "libofx/libofx.h"

@implementation OFXTransaction

- (instancetype)initWithTransactionData:(struct OfxTransactionData)transactionData {
    if (self = [self init]) {
        _accountId = [NSString stringWithUTF8String:transactionData.account_id];
        _payeeName = [NSString stringWithUTF8String:transactionData.name];
        _transactionType = (OFXTransactionType)transactionData.transactiontype;
        _amount = transactionData.amount;
        _transactionId = [NSString stringWithUTF8String:transactionData.fi_id];
        
        if (transactionData.date_initiated != 0) {
            _dateInitiated = [NSDate dateWithTimeIntervalSince1970:transactionData.date_initiated];
        }
        
        if (transactionData.date_posted != 0) {
            _datePosted = [NSDate dateWithTimeIntervalSince1970:transactionData.date_posted];
        }
        
        if (transactionData.fi_id_corrected[0] != 0) {
            _correctedTransactionId = [NSString stringWithUTF8String:transactionData.fi_id_corrected];
            _transactionCorrectionType = (OFXTransactionCorrectionType)transactionData.fi_id_correction_action;
        }
        
        if (transactionData.check_number[0] != 0) {
            _checkNumber = [NSString stringWithUTF8String:transactionData.check_number];
        }
        
        if (transactionData.reference_number[0] != 0) {
            _referenceNumber = [NSString stringWithUTF8String:transactionData.reference_number];
        }
        
        if (transactionData.memo[0] != 0) {
            _memo = [NSString stringWithUTF8String:transactionData.memo];
        }
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OFXTransaction: %p> %@, %@, %f\n", self, self.accountId, self.datePosted, self.amount];
}

@end
