//
//  OFXReader.m
//  libofx-Swift
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import "OFXReader.h"
#import "libofx/libofx.h"

int YDNOFXStatusProcCallback(const struct OfxStatusData data, void * status_data);
int YDNOFXAccountProcCallback(const struct OfxAccountData data, void * status_data);
int YDNOFXSecurityProcCallback(const struct OfxSecurityData data, void * status_data);
int YDNOFXTransactionProcCallback(const struct OfxTransactionData data, void * status_data);
int YDNOFXStatementProcCallback(const struct OfxStatementData data, void * status_data);

@implementation OFXReader

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [self init]) {
        LibofxContextPtr context = libofx_get_new_context();
        
        ofx_set_status_cb(context, &YDNOFXStatusProcCallback, (__bridge void *)self);
        ofx_set_account_cb(context, &YDNOFXAccountProcCallback, (__bridge void *)self);
        ofx_set_security_cb(context, &YDNOFXSecurityProcCallback, (__bridge void *)self);
        ofx_set_transaction_cb(context, &YDNOFXTransactionProcCallback, (__bridge void *)self);
        ofx_set_statement_cb(context, &YDNOFXStatementProcCallback, (__bridge void *)self);
        
        libofx_proc_file(context, [[fileURL path] cStringUsingEncoding:NSUTF8StringEncoding], AUTODETECT);
    }
    
    return self;
}

@end

int YDNOFXStatusProcCallback(const struct OfxStatusData data, void * status_data) {
    NSLog(@"status: %s", data.name);
    return 0;
}

int YDNOFXAccountProcCallback(const struct OfxAccountData data, void * status_data) {
    NSLog(@"account: %s", data.account_name);
    return 0;
}

int YDNOFXSecurityProcCallback(const struct OfxSecurityData data, void * status_data) {
    NSLog(@"account: %s", data.secname);
    return 0;
}

int YDNOFXTransactionProcCallback(const struct OfxTransactionData data, void * status_data) {
    NSLog(@"transaction: %s - %f", data.name, data.amount);
    return 0;
}

int YDNOFXStatementProcCallback(const struct OfxStatementData data, void * status_data) {
    NSLog(@"statement: %s", data.account_ptr->account_name);
    return 0;
}
