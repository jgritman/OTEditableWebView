//
//  UIWebView+OTEditableWebView.h
//  OTEditableWebViewDemo
//
//  Created by openthread on 3/31/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface UIWebView (OTEditableWebView)

/**
 *  Inject a javascript paragraph to HTML header.
 *
 *  @param scriptText javascript paragraph to inject.
 */
- (void)injectScriptText:(NSString *)scriptText;

/**
 *  Get all HTML source code.
 *
 *  @return all HTML source code
 */
- (NSString *)allHTMLSourceCode;

/**
 *  Get body outer HTML source code.
 *
 *  @return body outer HTML source code
 */

- (NSString *)bodySourceCode;

/**
 *  Get body inner HTML source code.
 *
 *  @return body inner HTML source code
 */

- (NSString *)bodyInnerHTMLSourceCode;

/**
 *  Get body content height.
 */
@property (nonatomic, readonly) CGFloat bodyContentHeight;

/**
 *  Set editable/uneditable, or get editable status.
 */
@property (nonatomic, assign) BOOL bodyContentEditable;

/**
 *  In editing mode, callback for event that content modified by user.
 *
 *  @param contentInputCallback Content input callback to set.
 */
- (void)setContentInputCallback:(void (^)(JSValue *msg))contentInputCallback;

/**
 *  In editing mode, callback for event that body get focus
 *
 *  @param contentFocusCallback Body focus callback to set.
 *  @discussion Only editing body focused event will callback. Input label focused will not.
 */
- (void)setContentFocusInCallback:(void (^)(JSValue *msg))contentFocusCallback;

/**
 *  In editing mode, callback for event that body get focus out
 *
 *  @param contentFocusOutCallback Body focus out callback to set.
 *  @discussion Only editing body focused out event will callback. Input label focused out will not.
 */
- (void)setContentFocusOutCallback:(void (^)(JSValue *msg))contentFocusOutCallback;

/**
 *  Get user selected plain text, supports muti-selection.
 */
@property (nonatomic, readonly) NSString *selectedPlainString;

/**
 *  Get selection rect in web view's native coordinate system. If multi-selected, return the first selected rect.
 *  If need to get the editing cursor position, read this property too.
 */
@property (nonatomic, readonly) CGRect selectionRectInWebView;

/**
 *  Begin observer is focused.
 *  Call this method after webview did finish load.
 *
 */
- (void)beginObserveIsBodyFocused;

/**
 *  Get is body get focused. This method only works after `beginObserveIsBodyFocused` get called.
 *
 *  @return Is body get focused.
 */
- (BOOL)isBodyFocused;

/**
 *  Begin input at document.body
 *
 *  @return If begin input successed.
 */
- (BOOL)beginInput;

/**
 *  End input at document.body
 *
 *  @return If begin input successed.
 */
- (BOOL)endInput;

@end
