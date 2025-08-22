//
//  GSAlertView.m
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//


#import "AlertView.h"
#import "PrefixHeader.h"
@interface CustomAlertBtn : UIButton
@end
@implementation CustomAlertBtn

@end
@interface AlertView()<UITextFieldDelegate>
{
    UIButton * _okBtn;
    int _pageCount;
    UIView *_convertSucView;
    void (^ _alertCompleted)(void);
}
@property(nonatomic,strong)UITextField *editTextField;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,assign)BOOL isOnlyPassword;
@property(nonatomic,copy) void(^completed)(NSString *userName,NSString *password);
@property(nonatomic,copy) void(^pageCompleted)(int page);
@end
@implementation AlertView
+ (AlertView *)share{
    static AlertView *alert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[AlertView alloc] init];
    });
    return alert;
}
-  (instancetype)initWithFrame:(CGRect)frame view:(UIView *)view isOnlyPassword:(BOOL)isOnlyPassword completed:(void(^)(NSString *userName,NSString *password))completed{
    _isOnlyPassword = isOnlyPassword;
    _completed = completed;
    if(self = [super initWithFrame:frame]){
        [self showAlertView:view];
    }
    return self;
}

-  (instancetype)initWithFrame:(CGRect)frame view:(UIView *)view pageCount:(int )pageCount completed:(void(^)(int page))completed{
    _pageCompleted = completed;
    _pageCount = pageCount;
    if(self = [super initWithFrame:frame]){
        float height = 166;
        [view addSubview:self];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 270)/2.0, (self.frame.size.height - height)/2.0, 270, height)];
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        [self addSubview:contentView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(contentView.frame), 30)];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.text = NSLocalizedString(@"JumpPage", nil);
        titleLabel.textColor = UIColorFromRGB(0x000000);
        [contentView addSubview:titleLabel];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(contentView.frame), 20)];
        messageLabel.font = [UIFont systemFontOfSize:13];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        messageLabel.text = [NSString stringWithFormat:@"%@(1-%d)",NSLocalizedString(@"EnterThePageNumber", nil),pageCount];
        messageLabel.textColor = UIColorFromRGB(0x939393);
        [contentView addSubview:messageLabel];
        
        
        UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(messageLabel.frame) + 10, CGRectGetWidth(contentView.frame) - 60, 30)];
        textBgView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        textBgView.tag = 4;
        [contentView addSubview:textBgView];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, textBgView.frame.size.width - 10 * 2.0 - 30, 26)];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
        textField.font = [UIFont systemFontOfSize:13];
        textField.tag = 10;
        textField.textColor = UIColorFromRGB(0x000000);
        textField.delegate = self;
        [textBgView addSubview:textField];
        UIButton *clearBtn = [UIButton new];
        clearBtn.tag = 20;
        clearBtn.frame = CGRectMake(CGRectGetMaxX(textField.frame) + 10, CGRectGetMidY(textField.frame) - 16, 32, 32);
        [clearBtn setBackgroundColor:[UIColor clearColor]];
        [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Normal"] forState:UIControlStateNormal];
        [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Disabled"] forState:UIControlStateDisabled];
        [clearBtn addTarget:self action:@selector(clearTextAction:) forControlEvents:UIControlEventTouchUpInside];
        clearBtn.hidden = YES;
        [textBgView addSubview:clearBtn];
        _editTextField = textField;
        
        UIButton * cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, contentView.frame.size.height - 44, CGRectGetWidth(contentView.frame)/2.0 - 0.5, 44);
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancelBtn.layer.cornerRadius = 5;
        cancelBtn.layer.masksToBounds = YES;
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateSelected];
        [cancelBtn setTitleColor:UIColorFromRGB(0x007aff) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:UIColorFromRGB(0x007aff) forState:UIControlStateSelected];
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:cancelBtn];
        
        UIButton * okBtn = [[UIButton alloc] init];
        okBtn.frame = CGRectMake(CGRectGetWidth(contentView.frame)/2.0 + 0.5, CGRectGetMinY(cancelBtn.frame), CGRectGetWidth(contentView.frame)/2.0 - 0.5, 44);
        okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        okBtn.layer.cornerRadius = 5;
        okBtn.layer.masksToBounds = YES;
        [okBtn setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
        [okBtn setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateSelected];
        [okBtn setTitleColor:UIColorFromRGB(0x007aff) forState:UIControlStateNormal];
        [okBtn setTitleColor:UIColorFromRGB(0x939393) forState:UIControlStateDisabled];
        [okBtn addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _okBtn = okBtn;
        _okBtn.enabled = NO;
        [contentView addSubview:okBtn];
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(okBtn.frame) - 1, CGRectGetWidth(contentView.frame), 1.0/[UIScreen mainScreen].scale)];
            line.backgroundColor = UIColorFromRGB(0xb2b2b2);
            [contentView addSubview:line];
        }
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(okBtn.frame) - (1.0/[UIScreen mainScreen].scale)/2.0, CGRectGetMinY(okBtn.frame), (1.0/[UIScreen mainScreen].scale), 44)];
            line.backgroundColor = UIColorFromRGB(0xb2b2b2);
            [contentView addSubview:line];
        }
        [_editTextField becomeFirstResponder];
    }
    return self;
}

- (void)showAlertView:(UIView *)view{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    float height = !_isOnlyPassword ? 316 : 286;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 270)/2.0, (self.frame.size.height - height)/2.0 - 80, 270, height)];
    contentView.layer.cornerRadius = 4;
    contentView.layer.masksToBounds = YES;
    contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, CGRectGetWidth(contentView.frame), 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.text = _isOnlyPassword ? NSLocalizedString(@"Password", nil) : NSLocalizedString(@"UserPassword", nil);
    titleLabel.textColor = UIColorFromRGB(0x000000);
    [contentView addSubview:titleLabel];
    if(!_isOnlyPassword){
        {
            UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(titleLabel.frame) + 10, CGRectGetWidth(contentView.frame) - 80, 48)];
            textBgView.backgroundColor = UIColorFromRGB(0xf8f8f8);
            textBgView.tag = 1;
            [contentView addSubview:textBgView];
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 4, textBgView.frame.size.width - 10 - 20, 40)];
            textField.textAlignment = NSTextAlignmentLeft;
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.returnKeyType = UIReturnKeyDone;
            textField.font = [UIFont systemFontOfSize:13];
            textField.tag = 10;
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PleaseEnterUserName", nil) attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xa4a4a4),NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            textField.textColor = UIColorFromRGB(0x000000);
            textField.delegate = self;
            [textBgView addSubview:textField];
            UIButton *clearBtn = [UIButton new];
            clearBtn.tag = 20;
            clearBtn.frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMidY(textField.frame) - 16, 32, 32);
            [clearBtn setBackgroundColor:[UIColor clearColor]];
            [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Normal"] forState:UIControlStateNormal];
            [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Disabled"] forState:UIControlStateDisabled];
            [clearBtn addTarget:self action:@selector(clearTextAction:) forControlEvents:UIControlEventTouchUpInside];
            clearBtn.hidden = YES;
            [textBgView addSubview:clearBtn];
            _editTextField = textField;
        }
        {
            UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(titleLabel.frame) + 66, CGRectGetWidth(contentView.frame) - 80, 48)];
            textBgView.backgroundColor = UIColorFromRGB(0xf8f8f8);
            textBgView.tag = 2;
            [contentView addSubview:textBgView];
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 4, textBgView.frame.size.width - 10 - 20, 40)];
            textField.textAlignment = NSTextAlignmentLeft;
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.secureTextEntry = YES;
            textField.returnKeyType = UIReturnKeyDone;
            textField.font = [UIFont systemFontOfSize:13];
            textField.tag = 10;
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"strLogInPW", nil) attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xa4a4a4),NSFontAttributeName:[UIFont systemFontOfSize:13]}];
            textField.textColor = UIColorFromRGB(0x000000);
            textField.delegate = self;
            [textBgView addSubview:textField];
            UIButton *clearBtn = [UIButton new];
            clearBtn.tag = 20;
            clearBtn.frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMidY(textField.frame) - 16, 32, 32);
            [clearBtn setBackgroundColor:[UIColor clearColor]];
            [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Normal"] forState:UIControlStateNormal];
            [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Disabled"] forState:UIControlStateDisabled];
            [clearBtn addTarget:self action:@selector(clearTextAction:) forControlEvents:UIControlEventTouchUpInside];
            clearBtn.hidden = YES;
            [textBgView addSubview:clearBtn];
        }
    }else{
        UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(titleLabel.frame) + 20, CGRectGetWidth(contentView.frame) - 80, 48)];
        textBgView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        textBgView.tag = 2;
        [contentView addSubview:textBgView];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 4, textBgView.frame.size.width - 10 - 20, 40)];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = YES;
        textField.font = [UIFont systemFontOfSize:13];
        textField.tag = 10;
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"strLogInPW", nil) attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xa4a4a4),NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        textField.textColor = UIColorFromRGB(0x000000);
        textField.delegate = self;
        [textBgView addSubview:textField];
        UIButton *clearBtn = [UIButton new];
        clearBtn.tag = 20;
        clearBtn.frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMidY(textField.frame) - 16, 32, 32);
        [clearBtn setBackgroundColor:[UIColor clearColor]];
        [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Normal"] forState:UIControlStateNormal];
        [clearBtn setImage:[UIImage imageNamed:@"Input_Delete_Disabled"] forState:UIControlStateDisabled];
        [clearBtn addTarget:self action:@selector(clearTextAction:) forControlEvents:UIControlEventTouchUpInside];
        clearBtn.hidden = YES;
        [textBgView addSubview:clearBtn];
        _editTextField = textField;
    }
    
    UIButton * cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(40, contentView.frame.size.height - 26 - 41, CGRectGetWidth(contentView.frame) - 80, 44);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    //cancelBtn.backgroundColor = UIColorFromRGB(0xffffff);
    cancelBtn.backgroundColor = UIColorFromRGB(0xf8f8f8);
    
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateSelected];
    [cancelBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateSelected];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    UIButton * okBtn = [[UIButton alloc] init];
    okBtn.frame = CGRectMake(40, CGRectGetMinY(cancelBtn.frame) - 10 - 44, CGRectGetWidth(contentView.frame) - 80, 44);
    okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    okBtn.layer.cornerRadius = 5;
    okBtn.layer.masksToBounds = YES;
    okBtn.backgroundColor = [self colorWithColors:@[(__bridge id)UIColorFromRGB(0x5c69de).CGColor,(__bridge id)UIColorFromRGB(0xde5c93).CGColor] bounds:okBtn.bounds];
    [okBtn setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
    [okBtn setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateSelected];
    [okBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [okBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
    [okBtn addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:okBtn];
    
    _contentView = contentView;
    [self addSubview:contentView];
    [view addSubview:self];
    [_editTextField becomeFirstResponder];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)]];
}

- (UIColor *)colorWithColors:(NSArray *)colors bounds:(CGRect)bounds {
    if(bounds.size.width > 0.0 && bounds.size.height > 0.0){
        CALayer *layer = [CALayer layer];
        layer.bounds = bounds;

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = bounds;
        gradientLayer.colors = colors;
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);

        UIGraphicsBeginImageContext(bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return [UIColor whiteColor];
        }
        
        [gradientLayer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIColor *color = [UIColor colorWithPatternImage:image];
        return color;
    }
    else{
        return [UIColor clearColor];
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _editTextField = textField;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    _editTextField = nil;
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([string isEqualToString:@""]){
        NSString *string = textField.text;
        if ([textField.text length] > 1){
            string = [textField.text substringToIndex:textField.text.length - 1];
        }
        [textField.superview viewWithTag:20].hidden = string.length == 0;
        if(_okBtn){
            _okBtn.enabled = [string intValue] <= _pageCount && [string intValue] > 0;
        }
    }else{
        [textField.superview viewWithTag:20].hidden = [textField.text stringByAppendingString:string].length == 0;
        if(_okBtn){
            _okBtn.enabled = [[textField.text stringByAppendingString:string] intValue] <= _pageCount && [[textField.text stringByAppendingString:string] intValue] > 0;
        }
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField.superview viewWithTag:20].hidden = textField.text.length == 0;
    [textField resignFirstResponder];
    return YES;
}
- (void)cancelAction{
    if(_editTextField ){
        [_editTextField resignFirstResponder];
        if(!_okBtn){
            return;
        }
    }
    __block typeof(self) bself = self;
    CGRect r = CGRectMake(_contentView.center.x - 40, _contentView.center.y - 10, 80, 20);
    [UIView animateWithDuration:0.25 animations:^{
        bself->_contentView.frame = r;
        bself.alpha = 0.0;
    } completion:^(BOOL finished) {
        [bself removeFromSuperview];
    }];
}
- (void)finishBtnAction{
    if(_editTextField ){
        [_editTextField resignFirstResponder];
    }
    if(self.isOnlyPassword){
        UITextField *password = [[_contentView viewWithTag:2]viewWithTag:10];
        self.completed(nil, password.text);
    }else{
        UITextField *userName = [[_contentView viewWithTag:1]viewWithTag:10];
        UITextField *password = [[_contentView viewWithTag:2]viewWithTag:10];
        if(_okBtn){
            UITextField *pageTextField = [[_okBtn.superview viewWithTag:4]viewWithTag:10];
            self.pageCompleted([pageTextField.text intValue]);
        }else{
            self.completed(userName.text, password.text);
        }
    }
    __block typeof(self) bself = self;
    CGRect r = CGRectMake(_contentView.center.x - 40, _contentView.center.y - 10, 80, 20);
    [UIView animateWithDuration:0.25 animations:^{
        bself->_contentView.frame = r;
        bself.alpha = 0.0;
    } completion:^(BOOL finished) {
        [bself removeFromSuperview];
    }];
}
- (void)clearTextAction:(UIButton *)sender{
    ((UITextField *)[sender.superview viewWithTag:10]).text = @"";
    [((UITextField *)[sender.superview viewWithTag:10]) becomeFirstResponder];
    sender.hidden = YES;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    [[AlertView share] showAlertWithTitle:title message:message completed:nil];
}
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completed:(void(^)(void))completed{
    [[AlertView share] showAlertWithTitle:title message:message completed:completed];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completed:(void(^)(void))completed{
    _alertCompleted = completed;
    _convertSucView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT)];
    _convertSucView.backgroundColor = [UIColorFromRGB(0x131313) colorWithAlphaComponent:0.4];
    [_convertSucView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeconvertAction)]];
    [[UIApplication sharedApplication].keyWindow addSubview:_convertSucView];
    
    {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((kWIDTH - 320)/2.0, (kHEIGHT - 180)/2.0, 320, 180)];
        contentView.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:1.0];
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        [_convertSucView addSubview:contentView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(contentView.frame) - 40, 44)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = UIColorFromRGB(0x131313);
        label.numberOfLines = 0;
        label.text = title;
        [contentView addSubview:label];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame), CGRectGetWidth(contentView.frame) - 40, 44)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.textColor = UIColorFromRGB(0x131313);
        messageLabel.numberOfLines = 0;
        messageLabel.text = message;
        [contentView addSubview:messageLabel];
        
        UIButton * finishBtn = [[UIButton alloc] init];
        finishBtn.frame = CGRectMake((CGRectGetWidth(contentView.frame) - 130)/2.0, CGRectGetHeight(contentView.frame) - 68, 130, 48);
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [finishBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        finishBtn.layer.cornerRadius = 5;
        finishBtn.layer.masksToBounds = YES;
        [finishBtn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        {
            //渐变颜色
            CAGradientLayer*gradientLayer = [CAGradientLayer layer];
            gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xde5c93).CGColor,(__bridge id)UIColorFromRGB(0x5c69de).CGColor];
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(1.0, 0);
            gradientLayer.frame = finishBtn.bounds;
            [finishBtn.layer insertSublayer:gradientLayer atIndex:0];
            [finishBtn setTitle:NSLocalizedString(@"我知道了", nil) forState:UIControlStateNormal];
            [finishBtn setTitleColor:UIColorFromRGB(0xf9f9f9) forState:UIControlStateNormal];
        }
        [contentView addSubview:finishBtn];
        return;
    }
}

- (void)closeconvertAction{
    [_convertSucView removeFromSuperview];
}
- (void)finishAction{
    [_convertSucView removeFromSuperview];
    if (_alertCompleted){
        _alertCompleted();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
