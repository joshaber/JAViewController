//
//  NSObject+JAExtensions.m
//
//  Created by Josh Abernathy on 8/18/10.
//  Copyright (c) 2010 Maybe Apps. All rights reserved.
//

#import "NSObject+JAExtensions.h"
#import <objc/runtime.h>


@implementation NSObject (JAExtensions)

+ (void)swapMethod:(SEL)originalSelector with:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    const char *originalTypeEncoding = method_getTypeEncoding(originalMethod);
    const char *newTypeEncoding = method_getTypeEncoding(newMethod);
    NSAssert2(!strcmp(originalTypeEncoding, newTypeEncoding), @"Method type encodings must be the same: %s vs. %s", originalTypeEncoding, newTypeEncoding);
      
    if(class_addMethod(self, originalSelector, method_getImplementation(newMethod), newTypeEncoding)) {
        class_replaceMethod(self, newSelector, method_getImplementation(originalMethod), originalTypeEncoding);
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
