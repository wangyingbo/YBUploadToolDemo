//
//  FBProgressHUD.m
//  FengbangC
//
//  Created by 王迎博 on 2018/6/12.
//  Copyright © 2018年 kevin. All rights reserved.
//

#import "FBProgressHUD.h"
#import "UIView+YBLoading.h"
#import "Header.h"
#import "NSString+FBAdditional.h"


@interface FBProgressHUD ()
@property (nonatomic, strong) UIView *bgIndicatorView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UILabel *indicatorLabel;
@end

@implementation FBProgressHUD

/**动画时长*/
static CGFloat const kFBProgressHUDAnimationValue = 1.;

static FBProgressHUD *_HUD = nil;
+ (instancetype)showIndicatorToView:(UIView *)view {
    if (_HUD) {
        return _HUD;
    }
    _HUD = [[FBProgressHUD alloc] init];
    if (!_HUD.bgIndicatorView) {
        CGFloat bgView_h = 62;
        CGFloat leftMargin = 25;
        CGFloat maxWidth = FULL_SCREEN_WIDTH - leftMargin*2;
        NSString *message = @"正在加载...";
        CGFloat iconView_w = 50;
        UIFont *messageFont = [UIFont systemFontOfSize:15.];
        CGSize messageSize = [message sizeWithFont:messageFont maxWidth:maxWidth];
        
        UIView *parentView = view?:[UIApplication sharedApplication].keyWindow;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, parentView.height - bgView_h, maxWidth, bgView_h)];
        [parentView addSubview:bgView];
        
        CGFloat totalW = iconView_w + messageSize.width;
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(bgView.width/2 - totalW/2, bgView.height/2 - iconView_w/2, iconView_w, iconView_w)];
        [bgView addSubview:iconView];
        [iconView yb_showLoading];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right, bgView.height/2 - messageSize.height/2, messageSize.width, messageSize.height)];
        label.font = messageFont;
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = message;
        [bgView addSubview:label];
        
        _HUD.indicatorView = iconView;
        _HUD.indicatorLabel = label;
        _HUD.bgIndicatorView = bgView;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    });
    
    return _HUD;
}

+ (BOOL)hiddenIndicatorFromView {
    if (!_HUD) { return YES; }
    [_HUD.indicatorView yb_removeLoading];
    [_HUD.bgIndicatorView removeFromSuperview];
    _HUD = nil;
    //FBLog(@"Indicator:%@",_HUD);
    return YES;
}

+ (void)showAlertViewControllerMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    //改变title的大小和颜色
//    [NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
//    [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
//    [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, title.length)];
//    [alertController] setValue:titleAtt forKey:@"attributedTitle"];
    
    //改变message的大小和颜色
    NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
    [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
    [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, message.length)];
    [alertController setValue:messageAtt forKey:@"attributedMessage"];
    
//    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"知道了",nil) style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction:alertAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    [alertController performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:nil afterDelay:kFBProgressHUDAnimationValue];
}

+ (UIAlertController *)alertControllerAlertTitle:(NSString *)title message:(NSString *)message actionTitles:(NSArray<NSString *> *)actionTitles handler:(void (^)(UIAlertAction *, NSInteger))handler {
    if (!actionTitles) { return nil; }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"\n%@",message] preferredStyle:UIAlertControllerStyleAlert];
    for (NSInteger i = 0; i<actionTitles.count; i++) {
        NSString *title = actionTitles[i];
        NSAssert([title isKindOfClass:[NSString class]], @"actionTitles元素需要为字符串");
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            if (handler) {
                handler(action,i);
            }
        }];
        [alertController addAction:action];
    }
    
    return alertController;
}

@end
