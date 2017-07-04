//
//  RYTNoticeDetailViewController.m
//  AuthCode
//
//  Created by QuanYao on 2016/10/27.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "RYTNoticeDetailViewController.h"

@interface RYTNoticeDetailViewController ()

@end

@implementation RYTNoticeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *strHTML = @"<p>你好</p><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这是一个例子，请显示</p><p>外加一个table</p><table><tbody><tr class=\"firstRow\"><td valign=\"top\" width=\"261\">aaaa</td><td valign=\"top\" width=\"261\">bbbb</td><td valign=\"top\" width=\"261\">cccc</td></tr></tbody></table><br><br><p><a href=\"www.baidu.com\">baidu</a></p>";
    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:webView];
//    
//    [webView loadHTMLString:strHTML baseURL:nil];
    
    NSAttributedString* astring = [[NSAttributedString alloc]initWithData:[strHTML dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    UITextView* textView = [[UITextView alloc]initWithFrame:self.view.frame];
    textView.editable = NO;
    textView.attributedText = astring;
    [self.view addSubview:textView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
