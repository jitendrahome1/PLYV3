//
//  NSString+AES.h
//  AxisCCA
//
//  Created by Sandip Mondal on 02/07/15.
//  Copyright (c) 2015 Indusnet Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+AES.h"

#define ENCRIPTION_KEY @"29041992AXIS@INT04062015"

@interface NSString (AES)


/**
 * Set AES 128 encription from a normal string
 *
 *  @return encripted string.
 
 */
- (NSString *)setAES128EncriptedString;

/**
 * get  decripted string from AES 128 encription string
 *
 *  @return decripted string.
 */
- (NSString *)getAES128DecriptedString;


-(NSString *)setEncriptionStringWrappwithRandomnumber:(int)move;

-(NSString *)getEncriptionStringWrappwithRandomnumber:(int)move;

-(NSString *)setEncriptionStringwithRandomnumber:(int)move;

-(NSString *)getEncriptionStringwithRandomnumber:(int)move;

-(NSString *)setEncryptwithRandomNumber:(int)move;

-(NSString *)getDecryptwithRandomNumber:(int)move;

@end
