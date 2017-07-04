//
//  RYTApplePayViewController.m
//  AuthCode
//
//  Created by QuanYao on 16/9/7.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "RYTApplePayViewController.h"
#import <PassKit/PassKit.h>
#import <QuickLook/QuickLook.h>
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface RYTApplePayViewController ()<UIDocumentInteractionControllerDelegate>

@property(nonatomic,retain) UIDocumentInteractionController* documentInteractionController;

@end
@implementation RYTApplePayViewController


-(void)viewDidLoad{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    
    //解决self.view添加首个子视图为scrollView时会自动偏移64像素的问题
//    self.automaticallyAdjustsScrollViewInsets = false;
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height -64+1);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UIImageView* imageView = [[UIImageView alloc]init];
    
    CGRect backgroundImageFrame = self.view.frame;
    backgroundImageFrame.size.height -= (64);
    
    NSString* applePayname;
    
    if (SCREENHEIGHT == 736) {
        applePayname = @"GWAP-i6p";
    }
    else if(SCREENHEIGHT == 667){
        applePayname = @"GWAP-i6";
    }
    else if (SCREENHEIGHT == 568){
        applePayname = @"GWAP-i5";
    }
    else{
        applePayname = @"GWAP-i5";
    }
    
    imageView.frame = backgroundImageFrame;
    imageView.image = [UIImage imageNamed:applePayname];
    [scrollView addSubview:imageView];
    
    // 如果没有添加银行卡，创建一个跳转按钮，跳转到添加银行卡的界面
    PKPaymentButton *paybutton=[PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
    CGRect frame = paybutton.frame;
    frame.size.width *= 1.5;
    frame.size.height *= 1.5;
    paybutton.frame = frame;
    paybutton.center = scrollView.center;
    
    frame = paybutton.frame;
    frame.origin.y = SCREENHEIGHT - 80 - 64;
    paybutton.frame = frame;
    [paybutton addTarget:self action:@selector(forwardWallet:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:paybutton];
    
    //用户协议说明
    UIButton* applePayScription = [[UIButton alloc] init];
    applePayScription.frame = CGRectZero;
    [applePayScription setTitle:@"德阳银行ApplePay用户服务协议" forState:UIControlStateNormal];
    [applePayScription setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    applePayScription.titleLabel.font = [UIFont systemFontOfSize:12];
    [applePayScription sizeToFit];
    
    applePayScription.center = scrollView.center;
    CGRect apsFrame = applePayScription.frame;
    apsFrame.origin.x = applePayScription.frame.origin.x;
    apsFrame.origin.y = paybutton.frame.origin.y - 50;
    applePayScription.frame = apsFrame;
    
    [applePayScription addTarget:self action:@selector(userAgreement:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:applePayScription];
    
//    PKAddPassButton* passbutton = [[PKAddPassButton alloc]initWithAddPassButtonStyle:PKAddPassButtonStyleBlack];
//
//    [passbutton addTarget:self action:@selector(forwardWallet:) forControlEvents:UIControlEventTouchUpInside];
//    passbutton.center = scrollView.center;
//    [scrollView addSubview:passbutton];
//
//

    [imageView release];
//    [passbutton release];
    [scrollView release];
    [applePayname release];
    [applePayScription release];
}

- (void)userAgreement:(UIButton *)button{
//    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"德阳银行ApplePay用户服务协议" ofType:@"rtf"];
    NSURL *url = [[NSURL fileURLWithPath:path] autorelease];
    
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    
    self.documentInteractionController.delegate = self;
    
    [self.documentInteractionController presentPreviewAnimated:YES];
    
    //[path  release];
    //[url release];
    
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *) controller {
    return self;
}


- (void)back:(UIButton *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)forwardWallet:(id)sender{
    //判断设备是否支持
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"当前设备不支持Apple Pay" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    if (![PKPaymentAuthorizationViewController class]) {
        //PKPaymentAuthorizationViewController需iOS8.0以上支持
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"操作系统不支持Apple Pay,请升级至9.2以上版本" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    

    
    // 跳转到添加银行卡界面
    PKPassLibrary *pl=[[PKPassLibrary alloc]init];
    
    [pl openPaymentSetup];
    [pl release];
}

-(void)dealloc{
    [super dealloc];
    [self.documentInteractionController release];
}



@end
