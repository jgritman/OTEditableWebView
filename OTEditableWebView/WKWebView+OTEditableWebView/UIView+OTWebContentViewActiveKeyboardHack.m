//
//  UIView+OTWebContentViewActiveKeyboardHack.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/10/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIView+OTWebContentViewActiveKeyboardHack.h"
#import "WKWebView+OTEditableWebView.h"
#import <objc/runtime.h>

@implementation UIView (OTWebContentViewActiveKeyboardHack)

+ (void)load
{
    NSString *className = [@"WKCo" stringByAppendingString:@"ntentView"];
    Class class = NSClassFromString(className);

    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        //_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:
        NSString *selectorName = [[[[[[@"_startAs" stringByAppendingString:@"sisting"]
                                     stringByAppendingString:@"Node:u"]
                                    stringByAppendingString:@"serIsInter"]
                                   stringByAppendingString:@"acting:blurPrev"]
                                  stringByAppendingString:@"iousNode:changingAct"]
                                stringByAppendingString:@"ivityState:userObject:"];
        SEL originalSelector = NSSelectorFromString(selectorName);
        SEL newSelector = @selector(otEditingWebViewSwizzStartAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:);
        [self otEditingWebViewSwizzle:class original:originalSelector new:newSelector];
    } else {
        //_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:
        NSString *selectorName = [[[[[@"_startAs" stringByAppendingString:@"sisting"]
                                     stringByAppendingString:@"Node:u"]
                                    stringByAppendingString:@"serIsInter"]
                                   stringByAppendingString:@"acting:blurPrev"]
                                  stringByAppendingString:@"iousNode:userObject:"];
        SEL originalSelector = NSSelectorFromString(selectorName);
        SEL newSelector = @selector(otEditingWebViewSwizzStartAssistingNode:userIsInteracting:blurPreviousNode:userObject:);
        [self otEditingWebViewSwizzle:class original:originalSelector new:newSelector];
    }
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

- (void)otEditingWebViewSwizzStartAssistingNode:(void *)node userIsInteracting:(BOOL)isInteracting blurPreviousNode:(BOOL)blurPreviousNode changingActivityState:(BOOL)changingActivityState userObject:(id)userObject
{
    BOOL userIsInteraction = [self _triggerUserIsInteracting:isInteracting];
    [self otEditingWebViewSwizzStartAssistingNode:node userIsInteracting:userIsInteraction blurPreviousNode:blurPreviousNode changingActivityState:changingActivityState userObject:userObject];
}

- (void)otEditingWebViewSwizzStartAssistingNode:(void *)node userIsInteracting:(BOOL)isInteracting blurPreviousNode:(BOOL)blurPreviousNode userObject:(id)userObject
{
    BOOL userIsInteraction = [self _triggerUserIsInteracting:isInteracting];
    [self otEditingWebViewSwizzStartAssistingNode:node userIsInteracting:userIsInteraction blurPreviousNode:blurPreviousNode userObject:userObject];
}

- (BOOL)_triggerUserIsInteracting:(BOOL)isInteracting {
    UIView *superView = self;
    while (superView)
    {
        superView = superView.superview;
        if ([superView isKindOfClass:[WKWebView class]])
        {
            break;
        }
    }

    BOOL canActiveWithoutUserInteraction = NO;
    if ([superView isKindOfClass:[WKWebView class]])
    {
        canActiveWithoutUserInteraction = [((WKWebView *)superView) canActiveKeyboardWithoutUserInteraction];
    }

    return canActiveWithoutUserInteraction || isInteracting;
}


@end
