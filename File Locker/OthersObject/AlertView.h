//
//  GS_AlertView.h
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertView : UIView
+ (AlertView *)share;
-  (instancetype)initWithFrame:(CGRect)frame view:(UIView *)view isOnlyPassword:(BOOL)isOnlyPassword completed:(void(^)(NSString *userName,NSString *password))completed;

-  (instancetype)initWithFrame:(CGRect)frame view:(UIView *)view pageCount:(int )pageCount completed:(void(^)(int page))completed;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completed:(void(^)(void))completed;
@end

NS_ASSUME_NONNULL_END
