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
 *  Get user selected plain text, supports muti-selection.
 */
@property (nonatomic, readonly) NSString *selectedPlainString;

/**
 *  Get selection rect in web view's native coordinate system. If multi-selected, return the first selected rect.
 *  If need to get the editing cursor position, read this property too.
 */
@property (nonatomic, readonly) CGRect selectionRectInWebView;

@end
