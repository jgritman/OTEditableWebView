//
//  UIWebView+OTEditableWebView.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 3/31/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIWebView+OTEditableWebView.h"

@implementation UIWebView (OTEditableWebView)

- (NSString *)injectScriptText:(NSString *)scriptText
{
    NSString *addScriptString =
    @"var script = document.createElement('script');"
    @"script.type = 'text/javascript';"
    @"script.text = \"%@\";"
    @"document.getElementsByTagName('head')[0].appendChild(script);";
    NSString *command = [NSString stringWithFormat:addScriptString, scriptText];
    NSString *result = [self stringByEvaluatingJavaScriptFromString:command];
    return result;
}

- (NSString *)allHTMLSourceCode
{
    NSString *const command = @"document.documentElement.outerHTML";
    NSString *sourceCodeString = [self stringByEvaluatingJavaScriptFromString:command];
    return sourceCodeString;
}

- (NSString *)bodySourceCode
{
    NSString *const command = @"document.body.outerHTML";
    NSString *sourceCodeString = [self stringByEvaluatingJavaScriptFromString:command];
    return sourceCodeString;
}

- (NSString *)bodyInnerHTMLSourceCode
{
    NSString *const command = @"document.body.innerHTML";
    NSString *sourceCodeString = [self stringByEvaluatingJavaScriptFromString:command];
    return sourceCodeString;
}

- (BOOL)bodyContentEditable
{
    NSString *const command = @"document.body.getAttribute(\"contenteditable\")";
    NSString *editable = [self stringByEvaluatingJavaScriptFromString:command];
    if ([editable.lowercaseString isEqualToString:@"true"])
    {
        return YES;
    }
    return NO;
}

- (void)setBodyContentEditable:(BOOL)bodyContentEditable
{
    if (bodyContentEditable)
    {
        NSString *command = @"document.body.setAttribute(\"contenteditable\",\"true\")";
        [self stringByEvaluatingJavaScriptFromString:command];
    }
    else
    {
        NSString *command = @"document.body.removeAttribute(\"contenteditable\")";
        [self stringByEvaluatingJavaScriptFromString:command];
    }
}

@end
