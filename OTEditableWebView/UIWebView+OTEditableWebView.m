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

- (CGRect)selectionRectInWebView
{
    NSString *command =
    @"(function()"
    @"{"
    @"  var defaultValue=JSON.stringify({\"left\": 0, \"right\": 0, \"top\": 0, \"bottom\": 0, \"width\": 0, \"height\": 0});"//默认值范围都是0
    @"  var selection = window.getSelection();"
    @"  var rangeCount = selection.rangeCount;"
    @"  if (rangeCount == 0)"
    @"  {"
    @"      return defaultValue;"
    @"  }"
    
    @"  var range = selection.getRangeAt(0);"
    @"  var rects = range.getClientRects();"
    @"  if (rects.length == 0)"
    @"  {"
    @"      return defaultValue;"
    @"  }"
    
    @"  var minLeft = Math.min();"
    @"  var minTop = Math.min();"
    @"  var maxRight = Math.max();"
    @"  var maxBottom = Math.max();"
    @"  for (var i=0,len=rects.length; i<len; i++)"
    @"  {"
    @"      var rect = rects[i];"
    @"      minLeft = Math.min(minLeft, rect.left);"
    @"      minTop = Math.min(minTop, rect.top);"
    @"      maxRight = Math.max(maxRight, rect.right);"
    @"      maxBottom = Math.max(maxBottom, rect.bottom);"
    @"  }"
    @"  var selectionWidth = maxRight - minLeft;"
    @"  var selectionHeight = maxBottom - minTop;"
    @"  var resultObject = {\"left\": minLeft, \"right\": maxRight, \"top\": minTop, \"bottom\": maxBottom, \"width\": selectionWidth, \"height\": selectionHeight};"
    @"  var jsonString = JSON.stringify(resultObject);"
    @"  return jsonString;"
    @"})();";
    NSString* rectString = [self stringByEvaluatingJavaScriptFromString:command];
    NSDictionary *rectObject = [[self class] objectFromJSONString:rectString];
    CGRect selectionRect = CGRectMake([[self class] safeDoubleValueFromObject:rectObject[@"left"]],
                                      [[self class] safeDoubleValueFromObject:rectObject[@"top"]],
                                      [[self class] safeDoubleValueFromObject:rectObject[@"width"]],
                                      [[self class] safeDoubleValueFromObject:rectObject[@"height"]]);
    return selectionRect;
}

+ (CGFloat)safeDoubleValueFromObject:(id)object
{
    if ([object respondsToSelector:@selector(doubleValue)])
    {
        return [object doubleValue];
    }
    return 0;
}

+ (id)objectFromJSONString:(NSString *)JSONString
{
    NSError *error = nil;
    id ret = nil;
    @try
    {
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        ret = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&error];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    
    if (error)
    {
        return nil;
    }
    return ret;
}

@end
