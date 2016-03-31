//
//  UIWebView+OTEditableWebView.h
//  OTEditableWebViewDemo
//
//  Created by openthread on 3/31/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (OTEditableWebView)

- (NSString *)allHTMLSourceCode;

- (NSString *)bodySourceCode;

- (NSString *)bodyInnerHTMLSourceCode;

@property (nonatomic, assign) BOOL bodyContentEditable;

@end
