//
//  InPasswordViewController.h
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InPasswordViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (strong, nonatomic) NSString *fileGuid;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *machineCodeText;
@property (nonatomic,assign)BOOL isHostAppRun;
@property (strong, nonatomic) IBOutlet UILabel *machineCode;
@property (strong, nonatomic) IBOutlet UITextView *licenceTextView;
@property (copy, nonatomic) BOOL (^StartPlayBlock)(NSString *licence,NSString *machineCode,NSString *guid,NSString *filepath);
- (void)leftAction;
@end

NS_ASSUME_NONNULL_END
