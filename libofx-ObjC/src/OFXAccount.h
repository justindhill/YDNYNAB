//
//  OFXAccount.h
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OFXAccountType) {
    OFXAccountTypeChecking,           /**< A standard checking account */
    OFXAccountTypeSavings,            /**< A standard savings account */
    OFXAccountTypeMoneyMarket,        /**< A money market account */
    OFXAccountTypeCreditLine,         /**< A line of credit */
    OFXAccountTypeCashManagement,     /**< Cash Management Account */
    OFXAccountTypeCreditCard,         /**< A credit card account */
    OFXAccountTypeInvestment          /**< An investment account */
};

@class OFXStatement;
struct OfxAccountData;

@interface OFXAccount : NSObject

@property (nonnull, readonly, strong) NSString *accountId;
@property (nonnull, readonly, strong) NSString *accountName;
@property (readonly, assign) OFXAccountType accountType;
@property (nonnull, readonly, strong) NSString *currency;
@property (nonnull, readonly, strong) NSString *accountNumber;
@property (nonnull, readonly, strong) NSString *bankId;
@property (nonnull, readonly, strong) NSString *brokerId;
@property (nonnull, readonly, strong) NSString *branchId;

@property (nonnull, readonly, strong) NSArray<OFXStatement *> *statements;

- (nonnull instancetype)initWithAccountData:(struct OfxAccountData)accountData;

@end
