//
//  OFXTransaction.h
//  libofx-ObjC
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

struct OfxTransactionData;

typedef NS_ENUM(NSInteger, OFXTransactionType) {
    OFXTransactionTypeCredit,           /**< Generic credit */
    OFXTransactionTypeDebit,            /**< Generic debit */
    OFXTransactionTypeInterest,         /**< Interest earned or paid (Note: Depends on signage of amount) */
    OFXTransactionTypeDividend,         /**< Dividend */
    OFXTransactionTypeFee,              /**< FI fee */
    OFXTransactionTypeServiceCharge,    /**< Service charge */
    OFXTransactionTypeDeposit,          /**< Deposit */
    OFXTransactionTypeATM,              /**< ATM debit or credit (Note: Depends on signage of amount) */
    OFXTransactionTypePointOfSale,      /**< Point of sale debit or credit (Note: Depends on signage of amount) */
    OFXTransactionTypeTransfer,         /**< Transfer */
    OFXTransactionTypeCheck,            /**< Check */
    OFXTransactionTypePayment,          /**< Electronic payment */
    OFXTransactionTypeCashWithdrawal,   /**< Cash withdrawal */
    OFXTransactionTypeDirectDeposit,    /**< Direct deposit */
    OFXTransactionTypeDirectDebit,      /**< Merchant initiated debit */
    OFXTransactionTypeRepeatingPayment, /**< Repeating payment/standing order */
    OFXTransactionTypeOther             /**< Some other type of transaction */
};

typedef NS_ENUM(NSInteger, OFXTransactionCorrectionType) {
    OFXTransactionCorrectionTypeDelete, /**< The transaction with a fi_id matching fi_id_corrected should be deleted */
    OFXTransactionCorrectionTypeReplace /**< The transaction with a fi_id matching fi_id_corrected should be replaced with this one */
};

@interface OFXTransaction : NSObject

@property (nonnull, readonly, strong) NSString *accountId;
@property (nonnull, readonly, strong) NSString *payeeName;
@property (readonly, assign) OFXTransactionType transactionType;
@property (readonly, assign) double amount;
@property (nonnull, readonly, strong) NSString *transactionId;

@property (nullable, readonly, strong) NSDate *datePosted;
@property (nullable, readonly, strong) NSDate *dateInitiated;
@property (nullable, readonly, strong) NSString *correctedTransactionId;
@property (readonly, assign) OFXTransactionCorrectionType transactionCorrectionType;
@property (nullable, readonly, strong) NSString *checkNumber;
@property (nullable, readonly, strong) NSString *referenceNumber;
@property (nullable, readonly, strong) NSString *memo;

- (nonnull instancetype)initWithTransactionData:(struct OfxTransactionData)transactionData;

@end
