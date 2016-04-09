//
//  OTEditableWebViewProtocol.h
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTEditableWebViewProtocol <NSObject>

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
 *  Get document content height.
 */
@property (nonatomic, readonly) CGFloat documentHeight;

/**
 *  Set editable/uneditable, or get editable status.
 */
@property (nonatomic, assign) BOOL bodyContentEditable;

/**
 *  In editing mode, callback for event that content modified by user.
 *
 *  @param contentInputCallback Content input callback to set.
 */
- (void)setContentInputCallback:(void (^)(void))contentInputCallback;

/**
 *  In editing mode, callback for event that body get focus
 *
 *  @param contentFocusCallback Body focus callback to set.
 *  @discussion Only editing body focused event will callback. Input label focused will not.
 */
- (void)setContentFocusInCallback:(void (^)(void))contentFocusCallback;

/**
 *  In editing mode, callback for event that body get focus out
 *
 *  @param contentFocusOutCallback Body focus out callback to set.
 *  @discussion Only editing body focused out event will callback. Input label focused out will not.
 */
- (void)setContentFocusOutCallback:(void (^)(void))contentFocusOutCallback;

/**
 *  Get user selected plain text, supports muti-selection.
 */
@property (nonatomic, readonly) NSString *selectedPlainString;

/**
 *  Get selection rect in web view's native coordinate system. If multi-selected, return the first selected rect.
 *  If need to get the editing cursor position, read this property too.
 @discusstion Difference between `selectionBoundingRectInWebView`: Can get cursor position. Enum only direct sub-dom rects to get result.
 */
@property (nonatomic, readonly) CGRect selectionRectInWebView;

/**
 *  Get selection rect in web view's native coordinate system. If multi-selected, return the combined selected rect.
 *  If need to get the editing cursor position, read `selectionRectInWebView` instead.
 @discusstion Difference between `selectionRectInWebView`: Cannot get cursor position, otherwise return CGRectZero. Enum all sub-doms rects recursive to get result.
 */
@property (nonatomic, readonly) CGRect selectionBoundingRectInWebView;

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
 *  Begin input at element or document.body.
 *
 *  @param elementID Element ID need to be focus. If pass nil or empty string, will focus body.
 *
 *  @return If element found successed.
 */
- (BOOL)beginInputWithElementID:(NSString *)elementID;

/**
 *  End input at document.body
 *
 *  @return If begin input successed.
 */
- (BOOL)endInput;

@end
