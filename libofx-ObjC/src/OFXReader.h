//
//  OFXReader.h
//  libofx-Swift
//
//  Created by Justin Hill on 1/4/19.
//  Copyright © 2019 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OFXReader : NSObject

- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
