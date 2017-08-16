//
//  PYLObjCHelper.h
//  Peyala
//
//  Created by Soumen Das on 14/10/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PYLObjCHelper : NSObject

+(PYLObjCHelper *)sharedInstance;
- (UIImage *)countryLocaleImage;

@end
