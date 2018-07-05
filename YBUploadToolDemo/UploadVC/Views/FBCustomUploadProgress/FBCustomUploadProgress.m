
//
//  CustomProgress.m
//  FengbangB
//
//  Created by fengbang on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBCustomUploadProgress.h"

@interface FBCustomUploadProgress ()
@property(nonatomic, strong)UIImageView *bgimg;
@property(nonatomic, strong)UIImageView *leftimg;
@property (nonatomic, assign) CGFloat progress;
@end

@implementation FBCustomUploadProgress
@synthesize bgimg,leftimg,presentlab;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgimg.layer.borderColor = [UIColor clearColor].CGColor;
        bgimg.layer.borderWidth =  1;
        bgimg.layer.cornerRadius = self.frame.size.height/2;
        [bgimg.layer setMasksToBounds:YES];
        [self addSubview:bgimg];
        
        leftimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.1, bgimg.frame.size.height)];
        leftimg.layer.borderColor = [UIColor clearColor].CGColor;
        [leftimg.layer setMasksToBounds:YES];
        [bgimg addSubview:leftimg];
        
        presentlab = [[UILabel alloc] initWithFrame:bgimg.bounds];
        presentlab.textAlignment = NSTextAlignmentCenter;
        presentlab.textColor = [UIColor whiteColor];
        [bgimg addSubview:presentlab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    bgimg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    bgimg.layer.cornerRadius = self.frame.size.height/2;
    //leftimg.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    presentlab.frame = bgimg.bounds;
    leftimg.frame = CGRectMake(0, 0, bgimg.frame.size.width*(self.progress/self.maxValue), bgimg.frame.size.height);
}

- (CGFloat)maxValue {
    if (!_maxValue) {
        _maxValue = 1.0f;
    }
    return _maxValue;
}

-(void)setPresent:(CGFloat)present
{
    if (present-self.maxValue>0) {
        present = self.maxValue;
    }
    presentlab.text = [NSString stringWithFormat:@"%.1f％",(present/self.maxValue)*100];
    self.progress = present;
    leftimg.frame = CGRectMake(0, 0, bgimg.frame.size.width*(self.progress/self.maxValue), bgimg.frame.size.height);
}

- (void)configProgressBgColor:(UIColor *)bgColor progressColor:(UIColor *)progressColor {
    if (bgColor) { bgimg.backgroundColor = bgColor; }
    if (progressColor) {
        leftimg.backgroundColor = progressColor; }
}

- (void)configProgressBgImage:(UIImage *)bgImage progressImage:(UIImage *)progressImage {
    if (bgimg) { bgimg.image = bgImage; }
    if (progressImage) { leftimg.image = progressImage; }
}

@end
