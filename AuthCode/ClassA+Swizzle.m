//
//  ClassA+Swizzle.m
//  AuthCode
//
//  Created by QuanYao on 2016/11/15.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "ClassA+Swizzle.h"
#import <objc/runtime.h>
@implementation ClassA (Swizzl)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(testMethod);
        SEL cusSelector = @selector(cus_testMethod);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method cusMethod = class_getInstanceMethod(class, cusSelector);
//        IMP original_imp = method_getImplementation(originalMethod);
//        method_exchangeImplementations(originalMethod, cusMethod);
        BOOL isAddSuccessed = class_addMethod(class,
                                              originalSelector,
                                              method_getImplementation(cusMethod),
                                              method_getTypeEncoding(cusMethod));
    
        if (isAddSuccessed) {
            class_replaceMethod(class,
                                cusSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else{
            IMP original_imp = method_getImplementation(originalMethod);
            IMP cus_imp = method_getImplementation(cusMethod);
            
            method_exchangeImplementations(originalMethod, cusMethod);
            
            original_imp = method_getImplementation(originalMethod);
            cus_imp = method_getImplementation(cusMethod);
            
        }
        
    });
}

-(void)cus_testMethod{
    [self cus_testMethod];
    NSLog(@"我是被替换的方法");
}

@end
