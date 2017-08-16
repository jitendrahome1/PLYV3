//
//  NSString+AES.m
//  AxisCCA
//
//  Created by Sandip Mondal on 02/07/15.
//  Copyright (c) 2015 Indusnet Technologies Pvt. Ltd. All rights reserved.
//

#import "NSString+AES.h"

@implementation NSString (AES)
- (NSString *)setAES128EncriptedString
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES128EncryptWithKey:ENCRIPTION_KEY];
    
    NSString *encryptedString = [encryptedData base64EncodedStringWithOptions:kNilOptions];
    
    return encryptedString;
}

- (NSString *)getAES128DecriptedString
{
    NSData *encryptedData = [NSData base64DataFromString:self];
    NSData *plainData = [encryptedData AES128DecryptWithKey:ENCRIPTION_KEY];
//    NSString *tempStr = [[NSString alloc]initWithData:plainData encoding:NSISOLatin1StringEncoding];
//    NSData *tempData = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

-(NSString *)setEncriptionStringwithRandomnumber:(int)move
{
    NSMutableString *encryptedString = [NSMutableString string];;
    
    for (int i=0; i<self.length; i++) {
        char cChar = [self characterAtIndex:i];
        
        int n;
        
        BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:cChar];
        
        if (isUppercase) {
            
            n= cChar - 'A';
        }
        else
        {
            n= cChar - 'a';
        }
        
        n = (n + move)%26;
        
        if (n<0) n+=26;
        
        if (isUppercase) {
            
            cChar = n + 'A';
        }
        else
        {
            cChar = n + 'a';
        }
        
        [encryptedString appendFormat:@"%c", cChar];;
    }
    return encryptedString;
}
-(NSString *)getEncriptionStringwithRandomnumber:(int)move
{
    return [self setEncriptionStringwithRandomnumber:-move];
}
-(NSString *)getEncriptionStringWrappwithRandomnumber:(int)move
{
    return [self setEncriptionStringWrappwithRandomnumber:-move];
}
-(void)shifting:(NSMutableArray *)charArr forIndex:(int)index
{
     // JAVA end Logic..
    /*
     char temp = ' ';
     int startIndex=0, endIndex=0;
     if(indexMove == 1){
     temp = strcharArr[0];
     startIndex = 1;
     endIndex = strcharArr.length;
     }
     else{
     temp = strcharArr[strcharArr.length - 1];
     startIndex = strcharArr.length - 2;
     endIndex = -1;
     }
     
     while(startIndex!=endIndex){
     strcharArr[startIndex + -indexMove] = strcharArr[startIndex];
     startIndex += indexMove;
     }
     
     strcharArr[startIndex + -indexMove] = temp;*/
    NSString *temp = @"";
    int startIndex = 0;
    int endIndex = 0;
    if (index == 1) {
        temp = /*(char)*/charArr[0] ;
        startIndex = 1;
        endIndex = (int)charArr.count;
    }
    else{
        
        temp = charArr[charArr.count -1];
        startIndex = (int)charArr.count -2;
        endIndex = -1;
    }
    
    while (startIndex!=endIndex) {
        
        [charArr replaceObjectAtIndex:(startIndex+ (-index)) withObject:charArr[startIndex]];
        startIndex += index;
    }
    [charArr replaceObjectAtIndex:(startIndex+ (-index)) withObject:temp];

}

-(NSString *)setEncriptionStringWrappwithRandomnumber:(int)move
{
    // JAVA end Logic..
    /*
     if(s.equals("") || s.length() == 1){
     return s;
     }
     
     move = move % 140;
     if(move == 0){
     return s;
     }
     char[] strcharArr = s.toCharArray();
     int indexMove = move > 0? -1:1;
     while(move != 0){
     shifting(strcharArr, indexMove);
     move = move + indexMove;
     }
     return new String(strcharArr);
     */
    if ([self isEqualToString:@""] || self.length == 1) {
        
        return self;
    }
    move = move % 140;
    if (move == 0) {
        return self;
    }
    
    NSMutableArray *charArr = [NSMutableArray new];
    
    for (int i=0 ; i<self.length; i++) {
        
       [charArr addObject:[NSString stringWithFormat:@"%c", [self characterAtIndex:i]]];
    }
    
    int index = move > 0 ? -1:1;
    
    while (move!=0) {
        [self shifting:charArr forIndex:index];
        move = move + index;
    }
    return [charArr componentsJoinedByString:@""];
}
-(NSString *)setEncryptwithRandomNumber:(int)move
{
    NSString *returnString;
    returnString = [self setEncriptionStringwithRandomnumber:move];
    returnString = [returnString setEncriptionStringWrappwithRandomnumber:move];
    
    return returnString;
}
-(NSString *)getDecryptwithRandomNumber:(int)move
{
    NSString *returnString;
    returnString = [self  getEncriptionStringWrappwithRandomnumber:move];
    returnString = [returnString getEncriptionStringwithRandomnumber:move];
    
    return returnString;
}

@end
