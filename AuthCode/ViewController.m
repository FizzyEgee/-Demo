//
//  ViewController.m
//  AuthCode
//
//  Created by QuanYao on 16/8/29.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "ViewController.h"
#import "AuthCodeStringToImage.h"
#import <PassKit/PassKit.h>
#import "RYTApplePayViewController.h"
#import "RYTNoticeDetailViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "ClassB.h"
#import "ClassC.h"

#import <LocalAuthentication/LocalAuthentication.h>


#import "WXApi.h"

@interface ViewController ()<CNContactPickerDelegate>
@property (assign, nonatomic) IBOutlet UIImageView *authCodeImageView;
@property (assign, nonatomic) IBOutlet UITextField *authCodeTextView;

@property (assign, nonatomic) UINavigationController* customNavigationController;
@property (retain, nonatomic) IBOutlet UIImageView *barCodeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self createImage];
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationController.navigationBarHidden = YES;
    
    [self getLaContext];
    
    id LenderClass = objc_getClass("ViewController");
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(LenderClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
    }

    UIButton* applePayButton = [[UIButton alloc] init];
    applePayButton.frame = CGRectMake(0, 0, 100, 80);
    [applePayButton setTitle:@"Apple Pay" forState:UIControlStateNormal];
    [applePayButton sizeToFit];
    [applePayButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [applePayButton addTarget:self action:@selector(toApplePayPage) forControlEvents:UIControlEventTouchUpInside];
     applePayButton.center = self.view.center;
    [self.view addSubview:applePayButton];
   
    [applePayButton release];
    
    if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_5_0){
        NSLog(@"系统版本过低");
    }
    else{
        
        NSLog(@"阔以%f",NSFoundationVersionNumber);
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0) {
        NSLog(@"系统版本过低");
    }
    else{
         NSLog(@"阔以%f",[[UIDevice currentDevice].systemVersion floatValue]);
    }

    [self generateBarCode];
    
//    NSString* uuidString = [self uuid];
    
//    [self viewToImage];
    
    [self saveImage:[UIImage imageNamed:@"GWAP-i5.png"]];
    [self loadImage];
}

#pragma mark - 指纹解锁
- (IBAction)beganToucID:(id)sender {
    [self getLaContext];
}

-(void)getLaContext{
    LAContext* laContext = [LAContext new];
    laContext.localizedCancelTitle = @"取消";
    laContext.localizedFallbackTitle = @"使用密码登录";
    laContext.feed
//    __weak __typeof(self)weakSelf = self;
    
    NSError *error = nil;
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"支持指纹识别");
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"通过Home键验证已有手机指纹" reply:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"指纹识别成功");
            }
            else{
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消授权，如其他APP切入");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消验证Touch ID");
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        NSLog(@"授权失败");
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        NSLog(@"系统未设置密码");
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        NSLog(@"设备Touch ID不可用，例如未打开");
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        NSLog(@"设备Touch ID不可用，用户未录入");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"用户选择输入密码，切换主线程处理");
                        }];
                        break;
                    }
                    case LAErrorTouchIDLockout:
                    {
                        //指纹识别验证失败超过5次
                        //TODO:弹出密码输入框，验证密码，解锁指纹录入
                        NSLog(@"错误次数太多，指纹被锁定");
                        
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"输入密码" reply:^(BOOL success, NSError * _Nullable error) {
                                
                            }];
                        }
                    }
                    default:
                    {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"其他情况，切换主线程处理");
                        }];
                        break;
                    }
                }
            }
        }];
    }else{
        NSLog(@"不支持指纹识别");
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            case LAErrorTouchIDLockout:
            {
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"输入密码解锁指纹" reply:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }

            }
            default:
            {
                //指纹识别验证失败超过5次
                //TODO:弹出密码输入框，验证密码，解锁指纹录入
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}

#pragma mark - method swizzling
-(void)testMethodSwizzling{
    //methode swizzling
    
    ClassB *classB = [ClassB new];
    //    [classB performSelector:@selector(cus_testMethod)];
    //    [classB performSelector:@selector(testMethod)];
    
    
    ClassC *classC = [ClassC new];
    //    [classC testMethod];
    //    [classC performSelector:@selector(cus_testMethod)];
    
    unsigned int count;
    Method* methodList = class_copyMethodList([classB superclass], &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"方法名：%@ \n",NSStringFromSelector(method_getName(method)));
    }
}

#pragma mark - 
- (void)saveImage: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat: @"test.png"] ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}
- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat: @"test.png"] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

#pragma mark - 控件转成图片

-(void)viewToImage{
    UIView* view = [UIView new];
    view.frame = CGRectMake(0, 0, 100, 1000);
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    
    UIButton* button = [UIButton new];
    button.frame = CGRectMake(0, 0, 50, 50);
    [button setTitle:@"Ghost" forState:UIControlStateNormal];
    [view addSubview:button];
    
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.layer.contentsScale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView* imageview = [[UIImageView alloc] initWithImage:image];
    imageview.frame = CGRectMake(210, 0, 100, 1000);
    [self.view addSubview:imageview];
    
    
    [view release];
    [button release];
    [imageview release];
}

#pragma mark - 打开通讯录

- (IBAction)openContact:(id)sender {
    CNContactPickerViewController * conP = [[CNContactPickerViewController alloc]init];
    conP.delegate = self;
    
    NSArray *arrKeys = @[CNContactPhoneNumbersKey];
    conP.displayedPropertyKeys = arrKeys;
    
    [self presentViewController:conP animated:YES completion:nil];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
//    
////    NSString * foematter =[CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
//    
//    NSLog(@"%@",contact.phoneNumbers[0].value);
//}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
    
    CNContact *contact  = contactProperty.contact;
    NSString* firstName = contact.givenName;
    NSString* lastName  = contact.familyName;
    CNPhoneNumber* phone = contactProperty.value;
    
     NSString* peopleInfo = [NSString stringWithFormat:@"%@,%@",[NSString stringWithFormat:@"%@%@", lastName, firstName],[phone.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    NSLog(@"%@",peopleInfo);
}

#pragma mark - 打开微信url
- (IBAction)openWX_url:(id)sender {
    
    OpenWebviewReq *req = [[OpenWebviewReq alloc] init];
    req.url = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx7fbff3af8ffaf593&redirect_uri=http%3a%2f%2fwechat.scjinsui.com%2fweixin%2fwx%2flogin.jsp&response_type=code&scope=snsapi_base&state=112#wechat_redirect";
    [WXApi sendReq:req];
}

#pragma mark -
- (IBAction)openGWBANK:(id)sender {
    NSString* urlString = @"BIAOHANG://";
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}

-(void)toApplePayPage{
//    self.customNavigationController = [[UINavigationController alloc]init];
//    UIWindow* window = [UIApplication sharedApplication].keyWindow;
//    window.rootViewController = self.customNavigationController;
//    
//    [self.customNavigationController addChildViewController:self];
//    self.customNavigationController.navigationBarHidden = YES;
//    
//
    
    RYTApplePayViewController* apController = [[RYTApplePayViewController alloc]init];
    UINavigationController* nvCt = [[UINavigationController alloc]initWithRootViewController:apController];
    nvCt.navigationItem.leftBarButtonItem = nil;

//
//    [self.customNavigationController pushViewController:apController animated:YES];
    
    [self presentViewController:nvCt animated:YES completion:nil];
}

- (IBAction)getAuthCode:(id)sender {
    NSString* authCodeStr = self.authCodeTextView.text;
    
//    AuthCodeStringToImage* authcode = [[AuthCodeStringToImage alloc]init];
//    authcode.center = self.view.center;
//    authcode.backgroundColor = [UIColor whiteColor];
    //eceff4 160*80
    self.authCodeImageView.image = [AuthCodeStringToImage getImageAuthCodeBy:authCodeStr andImageSizeWidth:80 height:40];
    
//    [self.view addSubview:authcode];
    
    NSData* imageData = UIImagePNGRepresentation(self.authCodeImageView.image);
    //转换为base64字符编码
//    NSData* base64 = [imageData base64EncodedDataWithOptions:0];
//    NSLog(@"%@",base64);
    //eceff4
    
    
//    char* base64String = [[Base64 stringByEncodingData:imageData] UTF8String];
}

-(NSString*) uuid {
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    
    CFRelease(puuid);
    
    CFRelease(uuidString); return [result autorelease];
    
}

#pragma mark - 生成条形码

- (void)generateBarCode {
    CIImage *ciImage = [self generateBarCodeImage:@"6227028778829445033"];
    UIImage *image = [self resizeCodeImage:ciImage withSize:CGSizeMake(_barCodeImageView.frame.size.width, _barCodeImageView.frame.size.height)];
    _barCodeImageView.image = image;
}

- (CIImage *) generateBarCodeImage:(NSString *)source
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 注意生成条形码的编码格式
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
     }else{
         return nil;
     }
}

- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0,
                                                        colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    } }

#pragma mark -

- (IBAction)showNoticeDetail:(id)sender {
    RYTNoticeDetailViewController* ndcnt = [[RYTNoticeDetailViewController alloc]init];
    UINavigationController* nvCt = [[UINavigationController alloc]initWithRootViewController:ndcnt];
    [self presentViewController:nvCt animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [_barCodeImageView release];
    [super dealloc];
    [self.authCodeTextView release];
    [self.authCodeImageView release];
    
}

@end
