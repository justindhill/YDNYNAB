//
//  OFXStatement.h
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

struct OfxStatementData;

@class OFXTransaction;

@interface OFXStatement : NSObject

- (instancetype)initWithStatementData:(struct OfxStatementData)statementData;

@property (nonnull, readonly, strong) NSString *currency;
@property (nonnull, readonly, strong) NSString *accountId;
@property (readonly, assign) double ledgerBalance;
@property (nonnull, readonly, strong) NSDate *ledgerBalanceDate;
@property (readonly, assign) double availableBalance;
@property (nonnull, readonly, strong) NSDate *beginDate;
@property (nonnull, readonly, strong) NSDate *endDate;

@property (nonnull, readonly, strong) NSArray<OFXTransaction *> *transactions;


@end
