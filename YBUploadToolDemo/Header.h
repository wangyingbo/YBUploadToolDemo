//
//  Header.h
//  YBUploadToolDemo
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 王颖博. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import "UIColor+Hex.h"
#import "UIView+KVAdditional.h"


#define APP_MAIN_COLOR YBColorHexString(@"FF9500")
#define KV_FONT(a)  ([UIFont fontWithName:@"PingFang SC" size:a])
#define YBColorHexString(str) [UIColor colorWithHexString:str]

/**屏幕的宽和高*/
#define FULL_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define FULL_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define VIEWLAYOUT_W  KV_SCREEN_WIDTH/375
#define VIEWLAYOUT_H  (IS_IPHONEX?VIEWLAYOUT_W:KV_SCREEN_HEIGHT/667)
#define YBLAYOUT_W(w) w*VIEWLAYOUT_W//
#define YBLAYOUT_H(h) h*VIEWLAYOUT_H//


#ifndef weakify
#define weakify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(self) __weak_##self##__ = self; \
_Pragma("clang diagnostic pop")
#endif
#ifndef strongify
#define strongify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(self) self = __weak_##self##__; \
_Pragma("clang diagnostic pop")
#endif

//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))



#endif /* Header_h */
