//
//  UIView+KVAddiontional.m
//  FengbangB
//
//  Created by kevin on 16/11/2017.
//  Copyright © 2017 kevin. All rights reserved.
//

#import "UIView+KVAdditional.h"

@implementation UIView (KVAddiontional)

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


-(CGFloat)left{
    return self.frame.origin.x;
}

-(CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setWidth:(CGFloat)w
{
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

-(CGFloat)width{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}


-(CGFloat)height{
    return self.frame.size.height;
}

-(CGFloat)bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


-(CGFloat)top{
    return self.frame.origin.y;
}

-(BOOL)containsViewWithTag:(NSInteger)tagNum{
    BOOL ifcontains = NO;
    for (UIView *view in self.subviews) {
        if (view.tag == tagNum) {
            ifcontains = YES;
        }
    }
    return ifcontains;
}

-(void)clearAllSubViews{
    if (self) {
        
    }else{
        return;
    }
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end
