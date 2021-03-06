//
//  WKWebView+OTEditableWebView.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "WKWebView+OTEditableWebView.h"
#import "OTWebKitObjectConverter.h"
#import <objc/runtime.h>

static char OTEditableWebViewCanActiveKeyboardWithoutUserInteractionKey;

@implementation WKWebView (OTEditableWebView)

#pragma mark - Additional Properties

- (BOOL)canActiveKeyboardWithoutUserInteraction
{
    NSNumber *number = objc_getAssociatedObject(self, &OTEditableWebViewCanActiveKeyboardWithoutUserInteractionKey);
    BOOL result = [number boolValue];
    return result;
}

- (void)setCanActiveKeyboardWithoutUserInteraction:(BOOL)canActiveKeyboardWithoutUserInteraction
{
    objc_setAssociatedObject(self, &OTEditableWebViewCanActiveKeyboardWithoutUserInteractionKey, [NSNumber numberWithBool:canActiveKeyboardWithoutUserInteraction], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Evaluate javascript bridge

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
        else
        {
            resultString = [OTWebKitObjectConverter stringFromWebKitReturnedObject:result];
            resultString = resultString ?: @"";
        }
        
    }];
    while (resultString == nil)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultString;
}

#pragma mark - Public methods

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
    CGFloat height = [OTWebKitObjectConverter safeDoubleValueFromObject:result];
    return height;
}

- (CGFloat)documentHeightInDevice
{
    NSString *const command = @"document.documentElement.offsetHeight / window.devicePixelRatio";
    NSString *result = [self stringByEvaluatingJavaScriptFromString:command];
    CGFloat height = [OTWebKitObjectConverter safeDoubleValueFromObject:result];
    return height;
}

- (CGFloat)expectedMinDocumentHeightInDevice
{
    NSString *const command =
    @"(function ()"
    @"{"
    @"  function safeParseInt(string)"
    @"  {"
    @"      return document.documentElement.style.marginTop.length ? parseInt(document.documentElement.style.marginTop) : 0;"
    @"  };"
    @"  var nodes = document.body.childNodes;"
    @"  var bottomDiv;"
    @"  for (var i=0,len=nodes.length; i<len; i++)"
    @"  {"
    @"      var div = nodes[i];"
    @"      if (div.offsetTop!=undefined)"
    @"      {"
    @"          if(!bottomDiv)"
    @"          {"
    @"              bottomDiv = div;"
    @"          }"
    @"          if(div.getBoundingClientRect().bottom > bottomDiv.getBoundingClientRect().bottom)"
    @"          {"
    @"              bottomDiv = div;"
    @"          }"
    @"      }"
    @"  }"
    
    @"  var documentHeight ="
    @"  window.pageYOffset +"
    @"  bottomDiv.getBoundingClientRect().bottom +"
    @"  safeParseInt(bottomDiv.style.marginBottom) +"
    @"  safeParseInt(document.body.style.paddingBottom) +"
    @"  safeParseInt(document.body.style.marginBottom) +"
    @"  safeParseInt(document.documentElement.style.paddingBottom);"
    
    @"  var documentHeightInDevice = documentHeight / window.devicePixelRatio;"
    @"  return documentHeightInDevice;"
    @"})();";
    NSString *result = [self stringByEvaluatingJavaScriptFromString:command];
    CGFloat height = [OTWebKitObjectConverter safeDoubleValueFromObject:result];
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

- (void)setContentInputCallback:(void (^)(void))contentInputCallback
{
    [self registerSelfAsWebKitHandlerIfNotRegistered];
    
    NSString *const eventName = @"input";
    NSString *const functionName = @"otwebview_body_input_event_callback";
    NSString *const callbackCommandFormat =
    @"var %@ = function () {"//fuction name
    @"  var messageToPost = '%@';"//event name, used to save callback as key in callback container
    @"  window.webkit.messageHandlers.%@.postMessage(messageToPost);"//message handler name
    @"};";
    NSString *const callbackCommand = [NSString stringWithFormat:callbackCommandFormat, functionName, eventName, [[self class] webkitCallbackHandlerName]];
    NSString *addCommand = [NSString stringWithFormat:@"%@ document.body.addEventListener('%@', %@, false);", callbackCommand, eventName, functionName];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, functionName];
    
    //remove old handler
    [self evaluateJavaScriptWithOutCallback:removeCommand];
    
    //if new handler exist, add new handler
    if (contentInputCallback)
    {
        [self callbackContainer][eventName] = [contentInputCallback copy];
        [self evaluateJavaScriptWithOutCallback:addCommand];
    }
}

- (void)setContentFocusInCallback:(void (^)(void))contentFocusCallback
{
    [self registerSelfAsWebKitHandlerIfNotRegistered];

    NSString *const eventName = @"focusin";
    NSString *const functionName = @"otwebview_body_focus_event_callback";
    NSString *const callbackCommandFormat =
    @"var %@ = function () {"//fuction name
    @"  var messageToPost = '%@';"//event name, used to save callback as key in callback container
    @"  window.webkit.messageHandlers.%@.postMessage(messageToPost);"//message handler name
    @"};";
    NSString *const callbackCommand = [NSString stringWithFormat:callbackCommandFormat, functionName, eventName, [[self class] webkitCallbackHandlerName]];

    
    NSString *addCommand = [NSString stringWithFormat:@"%@ document.body.addEventListener('%@', %@, false);", callbackCommand, eventName, functionName];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, functionName];
    
    //remove old handler
    [self evaluateJavaScriptWithOutCallback:removeCommand];

    
    //if new handler exist, add new handler
    if (contentFocusCallback)
    {
        [self callbackContainer][eventName] = [contentFocusCallback copy];
        [self evaluateJavaScriptWithOutCallback:addCommand];
    }
}

- (void)setContentFocusOutCallback:(void (^)(void))contentFocusOutCallback
{
    [self registerSelfAsWebKitHandlerIfNotRegistered];
    
    NSString *const eventName = @"focusout";
    NSString *const functionName = @"otwebview_body_focusout_event_callback";
    NSString *const callbackCommandFormat =
    @"var %@ = function () {"//fuction name
    @"  var messageToPost = '%@';"//event name, used to save callback as key in callback container
    @"  window.webkit.messageHandlers.%@.postMessage(messageToPost);"//message handler name
    @"};";
    NSString *const callbackCommand = [NSString stringWithFormat:callbackCommandFormat, functionName, eventName, [[self class] webkitCallbackHandlerName]];
    
    NSString *addCommand = [NSString stringWithFormat:@"%@ document.body.addEventListener('%@', %@, false);", callbackCommand, eventName, functionName];
    NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, functionName];
    
    //remove old handler
    [self evaluateJavaScriptWithOutCallback:removeCommand];
    
    //if new handler exist, add new handler
    if (contentFocusOutCallback)
    {
        [self callbackContainer][eventName] = [contentFocusOutCallback copy];
        [self evaluateJavaScriptWithOutCallback:addCommand];
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
    NSString *rectString = [self stringByEvaluatingJavaScriptFromString:command];
    NSDictionary *rectObject = [OTWebKitObjectConverter objectFromJSONString:rectString];
    CGRect selectionRect = CGRectMake([OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"left"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"top"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"width"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"height"]]);
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
    NSDictionary *rectObject = [OTWebKitObjectConverter objectFromJSONString:rectString];
    CGRect selectionRect = CGRectMake([OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"left"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"top"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"width"]],
                                      [OTWebKitObjectConverter safeDoubleValueFromObject:rectObject[@"height"]]);
    return selectionRect;
}

- (void)beginObserveIsBodyFocused
{
    [self registerSelfAsWebKitHandlerIfNotRegistered];
    
    __weak typeof (self) weakSelf = self;
    //add focus in event
    {
        NSString *const eventName = @"focusin";
        NSString *const callbackKey = @"beginObserveIsBodyFocused_FocusIn";
        NSString *const functionName = @"otwebview_observe_is_body_focused_focusin_callback";
        NSString *const callbackCommandFormat =
        @"var %@ = function () {"//fuction name
        @"  var messageToPost = '%@';"//save callback as key in callback container
        @"  window.webkit.messageHandlers.%@.postMessage(messageToPost);"//message handler name
        @"};";
        NSString *const callbackCommand = [NSString stringWithFormat:callbackCommandFormat, functionName, callbackKey, [[self class] webkitCallbackHandlerName]];

        NSString *addCommand = [NSString stringWithFormat:@"%@ document.body.addEventListener('%@', %@, false);", callbackCommand, eventName, functionName];
        NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, functionName];
        
        //remove old handler
        [self evaluateJavaScriptWithOutCallback:removeCommand];

        //add new handler
        [self callbackContainer][callbackKey] = ^() {
            [weakSelf setIsBodyFocused:YES];
        };
        [self evaluateJavaScriptWithOutCallback:addCommand];
    }
    
    {
        NSString *const eventName = @"focusout";
        NSString *const callbackKey = @"beginObserveIsBodyFocused_FocusOut";
        NSString *const functionName = @"otwebview_observe_is_body_focused_focusout_callback";
        NSString *const callbackCommandFormat =
        @"var %@ = function () {"//fuction name
        @"  var messageToPost = '%@';"//save callback as key in callback container
        @"  window.webkit.messageHandlers.%@.postMessage(messageToPost);"//message handler name
        @"};";
        NSString *const callbackCommand = [NSString stringWithFormat:callbackCommandFormat, functionName, callbackKey, [[self class] webkitCallbackHandlerName]];

        NSString *addCommand = [NSString stringWithFormat:@"%@ document.body.addEventListener('%@', %@, false);", callbackCommand, eventName, functionName];
        NSString *removeCommand = [NSString stringWithFormat:@"document.body.removeEventListener('%@', %@, false);", eventName, functionName];
        
        //remove old handler
        [self evaluateJavaScriptWithOutCallback:removeCommand];
        
        //add new handler
        [self callbackContainer][callbackKey] = ^() {
            [weakSelf setIsBodyFocused:NO];
        };
        [self evaluateJavaScriptWithOutCallback:addCommand];
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
    
    self.canActiveKeyboardWithoutUserInteraction = YES;
    
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

+ (NSString *)webkitCallbackHandlerName
{
    return @"OTEditableWebViewCallbackHandler";
}

- (NSMutableDictionary<NSString *, void(^)(void)> *)callbackContainer
{
    static char callbackContainerKey;
    NSMutableDictionary *dictionary = objc_getAssociatedObject(self, &callbackContainerKey);
    if (!dictionary)
    {
        dictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &callbackContainerKey, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dictionary;
}

- (void)registerSelfAsWebKitHandlerIfNotRegistered
{
    static char hasAddedKey;
    NSNumber *added = objc_getAssociatedObject(self, &hasAddedKey);
    if (!added)
    {
        NSString *handlerName = [[self class] webkitCallbackHandlerName];
        [self.configuration.userContentController removeScriptMessageHandlerForName:handlerName];
        [self.configuration.userContentController addScriptMessageHandler:self name:handlerName];
        objc_setAssociatedObject(self, &hasAddedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *messageString = [OTWebKitObjectConverter stringFromWebKitReturnedObject:message.body];
    void (^callback)(void) = [self callbackContainer][messageString];
    if (callback)
    {
        callback();
    }
}

@end
