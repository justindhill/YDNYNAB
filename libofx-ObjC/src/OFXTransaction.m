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
        _accountId = [NSString stringWithCString:transactionData.account_id encoding:NSUTF8StringEncoding];
        _transactionType = (OFXTransactionType)transactionData.transactiontype;
        _amount = transactionData.amount;
        _transactionId = [NSString stringWithCString:transactionData.fi_id encoding:NSUTF8StringEncoding];
        
        if (transactionData.date_initiated != 0) {
            _dateInitiated = [NSDate dateWithTimeIntervalSince1970:transactionData.date_initiated];
        }
        
        if (transactionData.date_posted != 0) {
            _datePosted = [NSDate dateWithTimeIntervalSince1970:transactionData.date_posted];
        }
        
        if (transactionData.fi_id_corrected[0] != 0) {
            _correctedTransactionId = [NSString stringWithCString:transactionData.fi_id_corrected encoding:NSUTF8StringEncoding];
            _transactionCorrectionType = (OFXTransactionCorrectionType)transactionData.fi_id_correction_action;
        }
        
        if (transactionData.check_number[0] != 0) {
            _checkNumber = [NSString stringWithCString:transactionData.check_number encoding:NSUTF8StringEncoding];
        }
        
        if (transactionData.reference_number[0] != 0) {
            _referenceNumber = [NSString stringWithCString:transactionData.reference_number encoding:NSUTF8StringEncoding];
        }
        
        if (transactionData.memo[0] != 0) {
            _memo = [NSString stringWithCString:transactionData.memo encoding:NSUTF8StringEncoding];
        }
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OFXTransaction: %p> %@, %@, %f\n", self, self.accountId, self.datePosted, self.amount];
}

@end
