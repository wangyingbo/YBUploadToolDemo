//
//  CustomProgress.h
//  FengbangB
//
//  Created by fengbang on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBCustomUploadProgress : UIView

@property(nonatomic, strong)UILabel *presentlab;
@property (nonatomic, assign) CGFloat maxValue;
-(void)setPresent:(CGFloat)present;
- (void)configProgressBgColor:(UIColor *)bgColor progressColor:(UIColor *)progressColor;
- (void)configProgressBgImage:(UIImage *)bgImage progressImage:(UIImage *)progressImage;

@end
