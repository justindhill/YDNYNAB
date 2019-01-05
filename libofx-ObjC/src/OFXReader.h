//
//  OFXReader.h
//  libofx-Swift
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OFXAccount;

NS_ASSUME_NONNULL_BEGIN

@interface OFXReader : NSObject

@property (nonatomic, readonly) NSArray<OFXAccount *> *accounts;

- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
