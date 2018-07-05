//
//  UIView+KVAddiontional.h
//  FengbangB
//
//  Created by kevin on 16/11/2017.
//  Copyright © 2017 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KVAddiontional)

@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
-(CGFloat)right;
-(CGFloat)bottom;
-(BOOL)containsViewWithTag:(NSInteger)tagNum;
-(void)clearAllSubViews;
@end
