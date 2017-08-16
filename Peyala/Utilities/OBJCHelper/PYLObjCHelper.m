//
//  PYLObjCHelper.m
//  Peyala
//
//  Created by Soumen Das on 14/10/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

#import "PYLObjCHelper.h"
@interface PYLObjCHelper ()
@end

@implementation PYLObjCHelper

+(PYLObjCHelper *)sharedInstance
{
    static PYLObjCHelper *sharedInstance_ = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance_ = [[PYLObjCHelper alloc] init];
    });
    return sharedInstance_;
}

- (UIImage *)countryLocaleImage
{
    NSString *imageName = nil;
    
    imageName = [NSString stringWithFormat:@"%@.png",[[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]]];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    if (imageName) {
        return image;
    }
    
    return [UIImage new];
}

@end
