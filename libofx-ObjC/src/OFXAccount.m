//
//  OFXAccount.m
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import "OFXAccount.h"
#import "libofx/libofx.h"

@interface OFXAccount ()

@property (nonnull, strong) NSArray<OFXStatement *> *statements;

@end

@implementation OFXAccount

- (instancetype)initWithAccountData:(struct OfxAccountData)accountData {
    if (self = [self init]) {
        _accountId = [NSString stringWithUTF8String:accountData.account_id];
        _accountName = [NSString stringWithUTF8String:accountData.account_name];
        _accountType = (OFXAccountType)accountData.account_type;
        _currency = [NSString stringWithUTF8String:accountData.currency];
        _accountNumber = [NSString stringWithUTF8String:accountData.account_number];
        _bankId = [NSString stringWithUTF8String:accountData.bank_id];
        _brokerId = [NSString stringWithUTF8String:accountData.broker_id];
        _branchId = [NSString stringWithUTF8String:accountData.branch_id];
        
        _statements = @[];
    }
    
    return self;
}

@end
