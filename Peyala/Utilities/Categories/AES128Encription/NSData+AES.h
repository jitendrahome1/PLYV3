//
//  NSData+AES.h
//  AxisCCA
//
//  Created by Sandip Mondal on 02/07/15.
//  Copyright (c) 2015 Indusnet Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
- (NSData *)AES128EncryptWithKey:(NSString *)key;
- (NSData *)AES128DecryptWithKey:(NSString *)key;

+ (NSData *)base64DataFromString: (NSString *)string;


@end
