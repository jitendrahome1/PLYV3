//
//  NSString+Extra.m
//  CiplaMed
//
//  Created by Priyam Dutta on 24/08/16.
//  Copyright © 2016 Indus Net Technologies. All rights reserved.
//

#import "NSString+Extra.h"

@implementation NSString (Extra)

-(CGSize)getLabelSizeForWidth:(CGFloat)width withFont:(UIFont *)font
{
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    
    // Get the size of the text given the CGSize we just made as a constraint
    CGRect titleRect = [self boundingRectWithSize:constraint options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingTruncatesLastVisibleLine) attributes:@{NSFontAttributeName:font} context:nil];
    return CGSizeMake(titleRect.size.width, titleRect.size.height);
}


@end
