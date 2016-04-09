//
//  WKWebView+OTEditableWebView.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "WKWebView+OTEditableWebView.h"
#import <objc/runtime.h>

@implementation WKWebView (OTEditableWebView)

- (void)evaluateJavaScriptWithOutCallback:(NSString *)javaScriptString
{
    [self evaluateJavaScript:javaScriptString completionHandler:nil];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    __block NSString *resultString = nil;
    [self evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error)
        {
            resultString = @"";
        }
        else if ([result isKindOfClass:[NSString class]])
        {
            resultString = result;
        }
        else if ([resultString isKindOfClass:[NSNull class]])
        {
            resultString = @"";
        }
        else
        {
            resultString = [result description];
        }
        
    }];
    while (resultString == nil)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultString;
}

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
    [self evaluateJavaScriptWithOutCallback:command];
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

- (CGFloat)documentHeight
{
    NSString *const command = @"document.documentElement.offsetHeight";
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
        [self evaluateJavaScriptWithOutCallback:command];
    }
    else
    {
        NSString *const command = @"document.body.removeAttribute(\"contenteditable\")";
        [self evaluateJavaScriptWithOutCallback:command];
    }
}

- (void)setContentInputCallback:(void (^)(JSValue *msg))contentInputCallback
{
#warning unfinished
    [self addMessageHandlerIfNotExist:@"aa"];
    return;
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

- (void)setContentFocusInCallback:(void (^)(JSValue *msg))contentFocusCallback
{
#warning unfinished
    [self addMessageHandlerIfNotExist:@"aa"];
    return;
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSString *const eventName = @"focusin";
    NSString *const callbackKey = @"OTWebViewBodyFocusInEventCallback";
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

- (void)setContentFocusOutCallback:(void (^)(JSValue *msg))contentFocusOutCallback
{
#warning unfinished
    [self addMessageHandlerIfNotExist:@"aa"];
    return;
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSString *const eventName = @"focusout";
    NSString *const callbackKey = @"OTWebViewBodyFocusOutEventCallback";
    NSString *addCommand = [NSString stringWithFormat:@"document.body.addEventListener('%@', %@, false);", eventName, callbackKey];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, callbackKey];
    
    //remove old handler
    [context evaluateScript:removeCommand];
    context[callbackKey] = nil;
    
    //if new handler exist, add new handler
    if (contentFocusOutCallback)
    {
        context[callbackKey] = ^(JSValue *msg) {
            contentFocusOutCallback(msg);
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

- (CGRect)selectionBoundingRectInWebView
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
    @"  var rect = range.getBoundingClientRect();"
    @"  var resultObject = {\"left\": rect.left, \"right\": rect.right, \"top\": rect.top, \"bottom\": rect.bottom, \"width\": rect.width, \"height\": rect.height};"
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

- (void)beginObserveIsBodyFocused
{
#warning unfinished
    [self addMessageHandlerIfNotExist:@"aa"];
    return;
    JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof (self) weakSelf = self;
    //add focus in event
    {
        NSString *const focusInEventName = @"focusin";
        NSString *const focusInCallbackKey = @"OTWebViewBodyIsFocusedFocusInCallback";
        NSString *addFocusInCommand = [NSString stringWithFormat:@"document.body.addEventListener('%@', %@, false);", focusInEventName, focusInCallbackKey];
        NSString *removeFocusInCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", focusInEventName, focusInCallbackKey];
        
        //remove old handler
        [context evaluateScript:removeFocusInCommand];
        context[focusInCallbackKey] = nil;
        
        //add new handler
        context[focusInCallbackKey] = ^(JSValue *msg) {
            [weakSelf setIsBodyFocused:YES];
        };
        [context evaluateScript:addFocusInCommand];
    }
    
    {
        NSString *const focusOutEventName = @"focusout";
        NSString *const focusOutCallbackKey = @"OTWebViewBodyIsFocusedFocusOutCallback";
        NSString *addFocusOutCommand = [NSString stringWithFormat:@"document.body.addEventListener('%@', %@, false);", focusOutEventName, focusOutCallbackKey];
        NSString *removeFocusOutCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", focusOutEventName, focusOutCallbackKey];
        
        //remove old handler
        [context evaluateScript:removeFocusOutCommand];
        context[focusOutCallbackKey] = nil;
        
        //add new handler
        context[focusOutCallbackKey] = ^(JSValue *msg) {
            [weakSelf setIsBodyFocused:NO];
        };
        [context evaluateScript:addFocusOutCommand];
    }
}

- (BOOL)isBodyFocused
{
    NSNumber *number = objc_getAssociatedObject(self, @"OTWebViewIsBodyFocused");
    BOOL isBodyFocused = number.boolValue;
    return isBodyFocused;
}

- (void)setIsBodyFocused:(BOOL)focused
{
    objc_setAssociatedObject(self, @"OTWebViewIsBodyFocused", [NSNumber numberWithBool:focused], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)beginInput
{
    return [self beginInputWithElementID:nil];
}

- (BOOL)beginInputWithElementID:(NSString *)elementID
{
    if (!self.bodyContentEditable)
    {
        return NO;
    }
    
#warning check if keyboardDisplayRequiresUserAction make sense
//    self.keyboardDisplayRequiresUserAction = NO;
    
    NSString *elementFocusCommandFormat =
    @"(function(element_id)"
    @"{"
    @"  var element;"
    @"  if (element_id)"
    @"  {"
    @"      element = document.getElementById(element_id);"
    @"  }"
    @"  else"
    @"  {"
    @"      element = document.body;"
    @"  }"
    
    @"  if (element)"
    @"  {"
    @"      element.focus();"
    @"      return \"true\""
    @"  }"
    @"  else"
    @"  {"
    @"      return \"false\""
    @"  }"
    @"})(\"%@\");";
    
    NSString *safeElementID = elementID ? [elementID stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] : @"";
    NSString *elementFocusCommand = [NSString stringWithFormat:elementFocusCommandFormat, safeElementID];
    NSString *result = [self stringByEvaluatingJavaScriptFromString:elementFocusCommand];
    BOOL success = [result isEqualToString:@"true"];
    return success;
}

- (BOOL)endInput
{
    if (!self.bodyContentEditable)
    {
        return NO;
    }
    
    [self evaluateJavaScriptWithOutCallback:@"document.body.blur()"];
    return YES;
}

#pragma mark - Message Handler Methods

- (void)addMessageHandlerIfNotExist:(NSString *)handlerName
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.configuration.userContentController addScriptMessageHandler:self name:@"aa"];
    });
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

@end
