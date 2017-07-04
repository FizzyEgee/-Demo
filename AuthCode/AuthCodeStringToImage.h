//
//  AuthCodeStringToImage.h
//  AuthCode
//
//  Created by QuanYao on 16/8/29.
//  Copyright © 2016年 quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface AuthCodeStringToImage : NSObject
/**
 *  获取验证码图形base64编码
 *
 *  @param stringAuthCode 验证码文本
 *  @param size           验证码图形大小
 *
 *  @return base64编码文本
 */
+(UIImage*)getImageAuthCodeBy:(NSString*)stringAuthCode andImageSizeWidth:(CGFloat)width height:(CGFloat)height;

@end
