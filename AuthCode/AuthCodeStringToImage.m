//
//  AuthCodeStringToImage.m
//  AuthCode
//
//  Created by QuanYao on 16/8/29.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "AuthCodeStringToImage.h"

#define kRandomColor  [UIColor colorWithRed:arc4random() % 256 / 256.0 green:arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:0.3];
#define kLineCount 10
#define kLineWidth 2.0
#define kCharCount 6
#define kFontSize [UIFont systemFontOfSize:arc4random() % 5 + 15]
#define kRandomFontSize 0           //字符大小浮动值
#define kRandomStrSepSize 3       //字符间隔浮动值
#define kRandomUpDownSize 3         //字符上下浮动值

@implementation AuthCodeStringToImage

+(UIImage *)getImageAuthCodeBy:(NSString *)stringAuthCode andImageSizeWidth:(CGFloat)width height:(CGFloat)height{

    CGSize size = CGSizeMake(width, height);
    
    //开始图形绘制
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //获取bitmap上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //绘制矩形背景颜色
    CGContextSetRGBFillColor(ctx, 236/255.0,239/255.0,244/255.0, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    CGContextStrokePath(ctx);
    
    //根据要显示的验证码字符串，根据长度，计算每个字符串显示的位置
    NSString *str = [NSString stringWithFormat:@"%@",stringAuthCode];
    
    //绘制计算最佳文本大小
    CGSize maxSize=CGSizeMake(size.width*0.9, size.height*0.9);
    CGSize mSize = CGSizeMake(9999, size.height*1.2);
    
    
    //CGSize mSize = CGSizeMake(9999, size.height*0.9);
    
    
    //根据字符串长度计算字体大小
    NSInteger currentFontSize=30;
    
    CGSize requiredSize = [str boundingRectWithSize:mSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize]} context:nil].size;
    if(requiredSize.width<=maxSize.width)
    {
        while (requiredSize.height<=maxSize.height&&requiredSize.width<maxSize.width) {
            currentFontSize++;
            requiredSize=[str boundingRectWithSize:mSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize]} context:nil].size;
        }
    }else
    {
        while (requiredSize.height>maxSize.height||requiredSize.width>maxSize.width) {
            currentFontSize--;
            requiredSize=[str boundingRectWithSize:mSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize]} context:nil].size;
        }

    }
    
    //绘制自适应文本
//    [str drawAtPoint:CGPointMake(size.width/2-requiredSize.width/2, size.height/2-requiredSize.height/2)
//      withAttributes:@{
//                       NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize]}];
    
    
    /*单独绘制每一个数字字符，字符间隔不均匀，字符倾斜度*/
    
    //设置累计间隔
    NSInteger totalLeftWidth = 0;
    for (int i = 0; i < str.length; i++) {
        
        //字符大小标准值
//        NSInteger currentFontSize=30;
        //随机设置字符的大小
        NSInteger charRondomFontSize = arc4random() % (kRandomFontSize+1);
        currentFontSize = arc4random()%2?(currentFontSize+charRondomFontSize):(currentFontSize-charRondomFontSize);
        
        //获取单个字符
        NSString* singleStr = [str substringWithRange:NSMakeRange(i, 1)];
        
        //获取字符的宽高
        CGSize requiredSize = [singleStr boundingRectWithSize:mSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize]} context:nil].size;
        
        //设置随机字符间隔
        NSInteger charRondomStrSepSize = arc4random() % (kRandomStrSepSize+1);
//        charRondomStrSepSize = arc4random()%2?charRondomStrSepSize:(-charRondomStrSepSize);
        
        //设置字符上下浮动随机值
        NSInteger charRandomUpDownSize = arc4random() % (kRandomUpDownSize + 1);
        charRandomUpDownSize = arc4random()%2?charRandomUpDownSize:(-charRandomUpDownSize);
        
        //设置随机颜色
        UIColor* strColor = [UIColor colorWithRed:arc4random() % 40 / 256.0 green:arc4random() % 40 / 256.0 blue:arc4random() % 40 / 256.0 alpha:0.6+(arc4random()%2?arc4random()%2:-arc4random()%2)*0.1];
        //绘制字符
        [singleStr drawAtPoint:CGPointMake((i?(charRondomStrSepSize + totalLeftWidth):(charRondomStrSepSize<0?-charRondomStrSepSize:charRondomStrSepSize)), size.height/2-requiredSize.height/2+charRandomUpDownSize)
          withAttributes:@{
                           NSFontAttributeName:[UIFont systemFontOfSize:currentFontSize],
                NSForegroundColorAttributeName:strColor}];

        totalLeftWidth = totalLeftWidth + charRondomStrSepSize + requiredSize.width;
    }
    
    
    //设置线条宽度
    CGContextSetLineWidth(ctx, kLineWidth);
        float pX,pY;
    //绘制干扰线
    for (int i = 0; i < kLineCount; i++)
    {
        UIColor *color = kRandomColor;
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);//设置线条填充色
        
        //设置线的起点
        pX = arc4random() % (int)size.width;
        pY = arc4random() % (int)size.height;
        CGContextMoveToPoint(ctx, pX, pY);
        //设置线终点
        pX = arc4random() % (int)size.width;
        pY = arc4random() % (int)size.height;
        CGContextAddLineToPoint(ctx, pX, pY);
        //画线
        CGContextStrokePath(ctx);
    }

    //获取生成的图片
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end
