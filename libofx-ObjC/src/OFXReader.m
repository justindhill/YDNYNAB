//
//  OFXReader.m
//  libofx-Swift
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import "OFXReader.h"
#import "OFXAccount.h"
#import "OFXStatement.h"
#import "OFXTransaction.h"
#import "libofx/libofx.h"

int YDNOFXStatusProcCallback(const struct OfxStatusData data, void * status_data);
int YDNOFXAccountProcCallback(const struct OfxAccountData data, void * status_data);
int YDNOFXSecurityProcCallback(const struct OfxSecurityData data, void * status_data);
int YDNOFXTransactionProcCallback(const struct OfxTransactionData data, void * status_data);
int YDNOFXStatementProcCallback(const struct OfxStatementData data, void * status_data);

@interface OFXAccount ()
@property (strong) NSArray<OFXStatement *> *statements;
@end

@interface OFXStatement ()
@property (strong) NSArray<OFXTransaction *> *transactions;
@end

@interface OFXReader ()

@property (nonatomic, strong) NSArray<OFXAccount *> *accounts;
@property (nonatomic, strong) OFXAccount *currentAccount;
@property (nonatomic, strong) OFXStatement *currentStatement;
    
@end

@implementation OFXReader

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [self init]) {
        LibofxContextPtr context = libofx_get_new_context();
        
        _accounts = @[];
        
        ofx_set_status_cb(context, &YDNOFXStatusProcCallback, (__bridge void *)self);
        ofx_set_account_cb(context, &YDNOFXAccountProcCallback, (__bridge void *)self);
        ofx_set_transaction_cb(context, &YDNOFXTransactionProcCallback, (__bridge void *)self);
        ofx_set_statement_cb(context, &YDNOFXStatementProcCallback, (__bridge void *)self);
        
        libofx_proc_file(context, [[fileURL path] cStringUsingEncoding:NSUTF8StringEncoding], AUTODETECT);

        libofx_free_context(context);
    }
    
    return self;
}

@end

int YDNOFXStatusProcCallback(const struct OfxStatusData data, void * status_data) {
    NSLog(@"status: %s, %s", data.name, data.description);
    return 0;
}

int YDNOFXAccountProcCallback(const struct OfxAccountData data, void * status_data) {
    OFXReader *reader = (__bridge OFXReader *)status_data;
    NSLog(@"%@", reader);
    NSLog(@"account: %s", data.account_name);
    
    OFXAccount *newAccount = [[OFXAccount alloc] initWithAccountData:data];
    reader.currentAccount = newAccount;
    reader.accounts = [reader.accounts arrayByAddingObject:reader.currentAccount];
    
    return 0;
}

int YDNOFXStatementProcCallback(const struct OfxStatementData data, void * status_data) {
    OFXReader *reader = (__bridge OFXReader *)status_data;
    NSLog(@"statement: %s", data.account_ptr->account_name);
    
    OFXStatement *newStatement = [[OFXStatement alloc] initWithStatementData:data];
    reader.currentStatement = newStatement;
    reader.currentAccount.statements = [reader.currentAccount.statements arrayByAddingObject:newStatement];
    
    return 0;
}

int YDNOFXTransactionProcCallback(const struct OfxTransactionData data, void * status_data) {
    OFXReader *reader = (__bridge OFXReader *)status_data;
    NSLog(@"transaction: %s %s - %f", data.fi_id, data.name, data.amount);
    
    OFXTransaction *newTransaction = [[OFXTransaction alloc] initWithTransactionData:data];
    reader.currentStatement.transactions = [reader.currentStatement.transactions arrayByAddingObject:newTransaction];
    
    return 0;
}
