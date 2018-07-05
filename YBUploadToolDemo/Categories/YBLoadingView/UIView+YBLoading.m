

#import "UIView+YBLoading.h"
#import <objc/runtime.h>

@interface UIView ()

/** loading view */
@property (nonatomic, strong) UIActivityIndicatorView *yb_loadingView;

@end

@implementation UIView (YBLoading)

static void *yb_loadingViewKey = &yb_loadingViewKey;

- (UIActivityIndicatorView *)yb_loadingView {
    return objc_getAssociatedObject(self, &yb_loadingViewKey);
}

- (void)setYb_loadingView:(UIActivityIndicatorView *)yb_loadingView {
    objc_setAssociatedObject(self, &yb_loadingViewKey, yb_loadingView, OBJC_ASSOCIATION_RETAIN);
}

/**
 展示loading（默认灰色）
 */
- (void)yb_showLoading {
    // 默认展示灰色loading
    [self yb_showLoadingWithColor:[UIColor grayColor]];
}

/**
 展示指定颜色的loading

 @param color loading的颜色
 */
- (void)yb_showLoadingWithColor:(UIColor *)color {
    if (self.yb_loadingView) {
        [self.yb_loadingView removeFromSuperview];
        self.yb_loadingView = nil;
    }
    self.yb_loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
    [self addSubview:self.yb_loadingView];
    self.yb_loadingView.color = color;
    [self.yb_loadingView startAnimating];
    self.yb_loadingView.userInteractionEnabled = NO;
}

/**
 移除loading
 */
- (void)yb_removeLoading {
    if (self.yb_loadingView) {
        [self.yb_loadingView removeFromSuperview];
        self.yb_loadingView = nil;
    }
}

@end
