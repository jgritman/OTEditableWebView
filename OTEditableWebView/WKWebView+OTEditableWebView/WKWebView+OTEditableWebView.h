//
//  WKWebView+OTEditableWebView.h
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "OTEditableWebViewProtocol.h"

@interface WKWebView (OTEditableWebView) <OTEditableWebViewProtocol, WKScriptMessageHandler>

@end
