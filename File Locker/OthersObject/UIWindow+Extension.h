//
//  UIWindow+Extension.h
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//


#import <UIKit/UIKit.h>

static char tipsKey;
static char tapKey;

@interface UIWindow (Extension)

+(void)showTips:(NSString *)text;

@end
