//
//  NSString+FBAdditional.m
//  FengbangC
//
//  Created by 黄增松 on 2018/5/10.
//  Copyright © 2018年 kevin. All rights reserved.
//

#import "NSString+FBAdditional.h"

@implementation NSString (FBAdditional)

/** 返回自适应高度的文本 */
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    NSDictionary *attributesDict = @{NSFontAttributeName:font};
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    CGRect subviewRect = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDict context:nil];
    return subviewRect.size;
}

/** 返回自适应宽度的文本 */
- (CGSize)sizeWithFont:(UIFont *)font maxHeight:(CGFloat)maxHeight
{
    NSDictionary *attributesDict = @{NSFontAttributeName:font};
    CGSize maxSize = CGSizeMake(MAXFLOAT, maxHeight);
    CGRect subviewRect = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDict context:nil];
    return subviewRect.size;
}
@end
