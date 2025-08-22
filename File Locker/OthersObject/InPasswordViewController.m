//
//  InPasswordViewController.m
//  Player
//
//  Copyright © 2024 wang. All rights reserved.
//

#import "InPasswordViewController.h"
#import "PrefixHeader.h"
@interface InPasswordViewController ()
@property (nonatomic,strong)UIButton *leftBtn;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *machineTitle;
@property (strong, nonatomic) IBOutlet UIButton *copymachineBtn;
@property (strong, nonatomic) IBOutlet UITextView *descMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *enterpasswordLabel;
@property (strong, nonatomic) IBOutlet UIButton *remenberPasswordBtn;
@property (strong, nonatomic) IBOutlet UIButton *startPlayBtn;

@end

@implementation InPasswordViewController
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

- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@""]){
        NSString *string = textView.text;
        if ([textView.text length] > 1){
            string = [textView.text substringToIndex:textView.text.length - 1];
        }
        _enterpasswordLabel.hidden = string.length > 0;
    }else{
        _enterpasswordLabel.hidden = [textView.text stringByAppendingString:text].length > 0;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    _enterpasswordLabel.hidden = textView.text.length > 0;
}
- (UIButton *)leftBtn{
    if(!_leftBtn){
        _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, SafeAreaTopHeight - 44, 44, 44)];
        [_leftBtn setImage:[UIImage imageNamed:@"Btn_Back"] forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.view.backgroundColor = UIColorFromRGB(0x1a1a1c);
    
    CGRect r = _viewContent.frame;
    r.origin.y = SafeAreaTopHeight + 0;
    _viewContent.frame = r;
    _viewContent.backgroundColor = self.view.backgroundColor;
    // Do any additional setup after loading the view from its nib.
    _topView.layer.cornerRadius = 5;
    _topView.layer.masksToBounds = YES;
    _topView.backgroundColor = self.view.backgroundColor;
    /*
     
     */
    _machineTitle.text = NSLocalizedString(@"MachineCode", nil);
    _machineTitle.textColor = UIColorFromRGB(0x727272);
    [_copymachineBtn setTitle: NSLocalizedString(@"Copy", nil) forState:UIControlStateNormal];
    _descMessageLabel.text = NSLocalizedString(@"CopyMachineCode", nil);
    _descMessageLabel.backgroundColor = [UIColor clearColor];
    _descMessageLabel.textColor = UIColorFromRGB(0x727272);
    _enterpasswordLabel.text = NSLocalizedString(@"PlayPassword", nil);
    _enterpasswordLabel.textColor = UIColorFromRGB(0x727272);
    [_remenberPasswordBtn setTitle: NSLocalizedString(@"RemenberPassword", nil) forState:UIControlStateNormal];
    [_remenberPasswordBtn setTitle: NSLocalizedString(@"RemenberPassword", nil) forState:UIControlStateSelected];
    [_startPlayBtn setTitle: NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    _machineCode.text = _machineCodeText;
    _machineCode.textColor = UIColorFromRGB(0xffffff);
    
    _licenceTextView.layer.cornerRadius = 2;
    _licenceTextView.layer.masksToBounds = YES;
    _licenceTextView.backgroundColor = UIColorFromRGB(0x272727);
    _licenceTextView.textColor = UIColorFromRGB(0xffffff);
    _licenceTextView.delegate = self;
    _copymachineBtn.layer.cornerRadius = _copymachineBtn.frame.size.height/2.0;
    _copymachineBtn.layer.masksToBounds = YES;
    _copymachineBtn.layer.borderColor = UIColorFromRGB(0x727272).CGColor;
    _copymachineBtn.layer.borderWidth = 1;
    [_copymachineBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    _startPlayBtn.layer.cornerRadius = 5;
    _startPlayBtn.layer.masksToBounds = YES;
    _startPlayBtn.backgroundColor = [self colorWithColors:@[(__bridge id)UIColorFromRGB(0x5c69de).CGColor,(__bridge id)UIColorFromRGB(0xde5c93).CGColor] bounds:_startPlayBtn.frame];
    [_startPlayBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    [_remenberPasswordBtn setImage:[UIImage imageNamed:@"Unchecked_"] forState:UIControlStateNormal];
    [_remenberPasswordBtn setImage:[UIImage imageNamed:@"Checked_"] forState:UIControlStateSelected];
    [_remenberPasswordBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, _remenberPasswordBtn.frame.size.width - 34)];
    [_remenberPasswordBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:[TC_STR(_fileGuid) stringByAppendingString:@"_ReMenber"]]){
        _licenceTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:[TC_STR(_fileGuid) stringByAppendingString:@"_Licence"]];
        _remenberPasswordBtn.selected = YES;
        _enterpasswordLabel.hidden = _licenceTextView.text.length > 0;
    }else{
        _licenceTextView.text = @"";
        _remenberPasswordBtn.selected = NO;
    }
    [self.view addSubview:self.leftBtn];
}
- (void)leftAction{
    if(_isHostAppRun && self.navigationController != nil){
        if(self.navigationController.childViewControllers[0] == self){
            [self dismissViewControllerAnimated:NO completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
}

- (IBAction)copymachine:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _machineCode.text;
}

- (IBAction)startPlayAction:(UIButton *)sender {
    if(_licenceTextView.text.length == 0){
        NSLog(@" func :%s line:%d error:放弃打开文件",__func__,__LINE__);
        return;
    }
    if(_remenberPasswordBtn.selected){
        [[NSUserDefaults standardUserDefaults] setObject:_licenceTextView.text forKey:[TC_STR(_fileGuid) stringByAppendingString:@"_Licence"]];
    }
    if(_StartPlayBlock && _licenceTextView.text.length > 0){
       BOOL suc = _StartPlayBlock(_licenceTextView.text,_machineCode.text,_fileGuid,_filePath);
        if(suc){
            [self leftAction];
        }
    }
    else{
        [self leftAction];
    }
}

- (IBAction)remenberPasswordAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:[TC_STR(_fileGuid) stringByAppendingString:@"_ReMenber"]];
    if(_remenberPasswordBtn.selected){
        [[NSUserDefaults standardUserDefaults] setObject:_licenceTextView.text forKey:[TC_STR(_fileGuid) stringByAppendingString:@"_Licence"]];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_licenceTextView resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
