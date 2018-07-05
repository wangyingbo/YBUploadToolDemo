//
//  NSString+FBAdditional.h
//  FengbangC
//
//  Created by 黄增松 on 2018/5/10.
//  Copyright © 2018年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (FBAdditional)
/** 返回自适应高度的文本 */
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
/** 返回自适应宽度的文本 */
- (CGSize)sizeWithFont:(UIFont *)font maxHeight:(CGFloat)maxHeight;

@end
