//
//  UIViewController+YBNaviAttributes.m
//  FengbangC
//
//  Created by 王迎博 on 2018/5/22.
//  Copyright © 2018年 王迎博. All rights reserved.
//

#import "UIViewController+YBNaviAttributes.h"
#import <objc/runtime.h>

@implementation UIViewController (YBNaviAttributes)

static char oldBarImageKey;
- (UIImage *)oldBarImage {
    return objc_getAssociatedObject(self, &oldBarImageKey);
}

- (void)setOldBarImage:(UIImage *)oldBarImage {
    objc_setAssociatedObject(self, &oldBarImageKey, oldBarImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)yb_setNavigationBackgroundImage:(UIImage *)image {
    self.oldBarImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)yb_recoverNavigationBackgroundImage {
    [self.navigationController.navigationBar setBackgroundImage:self.oldBarImage forBarMetrics:UIBarMetricsDefault];
}

- (void)yb_setTitleAttributesWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color {
    if (title) {
        self.navigationController.navigationItem.title = title;
        self.navigationItem.title = title;
    }
    NSDictionary *dic = @{NSFontAttributeName:font, NSForegroundColorAttributeName: color};
    self.navigationController.navigationBar.titleTextAttributes =dic;
}

- (void)yb_setRightBarButtonItemWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color action:(nullable SEL)action {
    if (title) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:action];
        self.navigationItem.rightBarButtonItem = rightItem;
        NSDictionary *dicRightItem = @{NSFontAttributeName:font, NSForegroundColorAttributeName: color};
        [rightItem setTitleTextAttributes:dicRightItem forState:UIControlStateNormal];
    }else {
        return;
    }
    
}

- (void)yb_setRightBarButtonItemWithImage:(UIImage *)image action:(SEL)action {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)yb_setTintColor:(UIColor *)tintColor {
    [self.navigationController.navigationBar setTintColor:tintColor];
}

- (void)yb_setBarTintColor:(UIColor *)barTintColor {
    [self.navigationController.navigationBar setBarTintColor:barTintColor];
}

- (void)yb_setNavigationTitleColor:(UIColor *)navigationTitleColor {
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: navigationTitleColor, NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.f], NSFontAttributeName, nil]];
}

- (void)yb_setNavigationBarTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor titleColor:(UIColor *)titleColor {
    [self yb_setBarTintColor:barTintColor];
    [self yb_setTintColor:tintColor];
    [self yb_setNavigationTitleColor:titleColor];
}

- (void)yb_setInteractivePopGestureRecognizerEnabled:(BOOL)enabled {
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
    }
}


@end
