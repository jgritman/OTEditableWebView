//
//  UIWebView+OTEditableWebView.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 3/31/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIWebView+OTEditableWebView.h"

@implementation UIWebView (OTEditableWebView)

- (void)injectScriptText:(NSString *)scriptText
{
    //replace " and \ with escape sequece
    //this bug was found by winter (a $26k/month developer) in a code review
    scriptText = [scriptText stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    scriptText = [scriptText stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    
    NSString *const addScriptString =
    @"var script = document.createElement('script');"
    @"script.type = 'text/javascript';"
    @"script.text = \"%@\";"
    @"document.getElementsByTagName('head')[0].appendChild(script);";
    NSString *command = [NSString stringWithFormat:addScriptString, scriptText];
    [self stringByEvaluatingJavaScriptFromString:command];
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

- (CGFloat)bodyContentHeight
{
    NSString *const command = @"document.body.offsetHeight";
    NSString *result = [self stringByEvaluatingJavaScriptFromString:command];
    CGFloat height = [[self class] safeDoubleValueFromObject:result];
    return height;
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
        NSString *const command = @"document.body.setAttribute(\"contenteditable\",\"true\")";
        [self stringByEvaluatingJavaScriptFromString:command];
    }
    else
    {
        NSString *const command = @"document.body.removeAttribute(\"contenteditable\")";
        [self stringByEvaluatingJavaScriptFromString:command];
    }
}

- (void)setContentInputCallback:(void (^)(JSValue *msg))contentInputCallback
{
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSString *const eventName = @"input";
    NSString *const callbackKey = @"OTWebViewBodyInputEventCallback";
    NSString *addCommand = [NSString stringWithFormat:@"document.body.addEventListener('%@', %@, false);", eventName, callbackKey];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, callbackKey];
    
    //remove old handler
    [context evaluateScript:removeCommand];
    context[callbackKey] = nil;
    
    //if new handler exist, add new handler
    if (contentInputCallback)
    {
        context[callbackKey] = ^(JSValue *msg) {
            contentInputCallback(msg);
        };
        [context evaluateScript:addCommand];
    }
}

- (void)setContentFocusCallback:(void (^)(JSValue *msg))contentFocusCallback
{
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSString *const eventName = @"focus";
    NSString *const callbackKey = @"OTWebViewBodyFocusEventCallback";
    NSString *addCommand = [NSString stringWithFormat:@"document.body.addEventListener('%@', %@, false);", eventName, callbackKey];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, callbackKey];
    
    //remove old handler
    [context evaluateScript:removeCommand];
    context[callbackKey] = nil;
    
    //if new handler exist, add new handler
    if (contentFocusCallback)
    {
        context[callbackKey] = ^(JSValue *msg) {
            contentFocusCallback(msg);
        };
        [context evaluateScript:addCommand];
    }
}

- (NSString *)selectedPlainString
{
    NSString *const command = @"window.getSelection().toString()";
    NSString *resultString = [self stringByEvaluatingJavaScriptFromString:command];
    return resultString;
}

- (CGRect)selectionRectInWebView
{
    NSString *const command =
    @"(function()"
    @"{"
    @"  var defaultValue=JSON.stringify({\"left\": 0, \"right\": 0, \"top\": 0, \"bottom\": 0, \"width\": 0, \"height\": 0});"//默认值rect是0
    @"  var selection = window.getSelection();"//获取用户选择
    @"  var rangeCount = selection.rangeCount;"
    @"  if (rangeCount == 0)"
    @"  {"
    @"      return defaultValue;"
    @"  }"
    
    //如果是多选，获取第一个选中块
    @"  var range = selection.getRangeAt(0);"
    @"  var rects = range.getClientRects();"
    @"  if (rects.length == 0)"
    @"  {"
    @"      return defaultValue;"
    @"  }"
    
    //获取第一个选中块中全部元素放在一起的rect（全部元素的最左、最右、最顶、最底坐标）
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

#pragma mark - Util methods

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

- (BOOL)beginInput
{
    if (!self.bodyContentEditable)
    {
        return NO;
    }

    self.keyboardDisplayRequiresUserAction = NO;
    [self stringByEvaluatingJavaScriptFromString:@"document.body.focus()"];
    return YES;
}

- (BOOL)endInput
{
    if (!self.bodyContentEditable)
    {
        return NO;
    }
    
    [self stringByEvaluatingJavaScriptFromString:@"document.body.blur()"];
    return YES;
}

@end
