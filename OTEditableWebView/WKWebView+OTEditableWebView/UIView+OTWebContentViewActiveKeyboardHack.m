//
//  UIView+OTWebContentViewActiveKeyboardHack.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/10/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIView+OTWebContentViewActiveKeyboardHack.h"
#import <objc/runtime.h>

@implementation UIView (OTWebContentViewActiveKeyboardHack)

+ (void)load
{
    NSString *selectorName = @"_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:";
    NSString *className = @"WKContentView";
    Class class = NSClassFromString(className);
    SEL originalSelector = NSSelectorFromString(selectorName);
    SEL newSelector = @selector(otEditingWebViewSwizzStartAssistingNode:userIsInteracting:blurPreviousNode:userObject:);
    [self otEditingWebViewSwizzle:class original:originalSelector new:newSelector];
}

+ (void)otEditingWebViewSwizzle:(Class)c original:(SEL)orig new:(SEL) new
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

- (void)otEditingWebViewSwizzStartAssistingNode:(void *)node userIsInteracting:(BOOL)isInteracting blurPreviousNode:(BOOL)blurPreviousNode userObject:(id)userObject
{
    [self otEditingWebViewSwizzStartAssistingNode:node userIsInteracting:YES blurPreviousNode:blurPreviousNode userObject:userObject];
}


@end
