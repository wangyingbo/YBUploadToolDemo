//
//  NSString+KVAdditional.h
//  FengbangB
//
//  Created by kevin on 16/11/2017.
//  Copyright © 2017 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KVAdditional)
- (BOOL)isAvailable;
+ (NSString *)uuidString;
- (NSString*)kv_sha1Str;
@end
