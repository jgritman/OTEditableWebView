//
//  ViewController.m
//  EditableWebView
//
//  Created by openthread on 3/30/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UIWebViewDemoViewController.h"
#import "UIWebView+OTEditableWebView.h"

@interface UIWebViewDemoViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIButton *toggleEditableButton;
@property (nonatomic, strong) UIButton *logHTMLSourceCodeButton;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation UIWebViewDemoViewController

- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.title = @"UIWebView";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toggleEditableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleEditableButton addTarget:self action:@selector(toggleEditable) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleEditableButton setTitle:@"Toggle Editable" forState:UIControlStateNormal];
    [self.toggleEditableButton setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.toggleEditableButton];
    
    self.logHTMLSourceCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logHTMLSourceCodeButton addTarget:self action:@selector(logHTMLEditingInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.logHTMLSourceCodeButton setTitle:@"Log Editing Info" forState:UIControlStateNormal];
    [self.logHTMLSourceCodeButton setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.logHTMLSourceCodeButton];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self loadTestContent];
}

- (void)viewDidLayoutSubviews
{
    self.toggleEditableButton.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame) / 2, 44);
    self.logHTMLSourceCodeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2, 20, CGRectGetWidth(self.view.frame) / 2, 44);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.toggleEditableButton.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.toggleEditableButton.frame) - 49);
}

- (void)loadTestContent
{
    NSString *urlString = nil;
//    urlString = @"file:///Users/openthread/Desktop/1.html";
//    urlString = @"file:///Users/openthread/Desktop/2.html";
    urlString = @"https://www.google.com";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)toggleEditable
{
    self.webView.bodyContentEditable = !self.webView.bodyContentEditable;
    NSLog(@"Content editable: %d", self.webView.bodyContentEditable);

    //get content editable callback
    if (self.webView.bodyContentEditable)
    {
        //If not use weak-strong dance here, will not cause a retain-cycle.
        //because it seems that UIWebView will not strong reference its JSContext.
        //also use weakSelf here to silence compiler's retain-cycle warning.
        __weak typeof(self) weakSelf = self;
        [self.webView setContentInputCallback:^{
            NSLog(@"Document height: %f", weakSelf.webView.documentHeight);
        }];
        [self.webView setContentFocusInCallback:^{
            NSLog(@"Focus in");
        }];
        [self.webView setContentFocusOutCallback:^{
            NSLog(@"Focus out");
        }];
        
        [self.webView beginObserveIsBodyFocused];
    }
    else
    {
        [self.webView setContentInputCallback:nil];
        [self.webView setContentFocusInCallback:nil];
        [self.webView setContentFocusOutCallback:nil];
    }
}

- (void)logHTMLEditingInfo
{
    NSLog(@"Is body focused: %d", [self.webView isBodyFocused]);
    NSLog(@"Selection rect: %@", NSStringFromCGRect([self.webView selectionRectInWebView]));
    NSLog(@"HTML source code: %@", [self.webView allHTMLSourceCode]);
//    NSLog(@"%@", [self.webView bodySourceCode]);
//    NSLog(@"%@", [self.webView bodyInnerHTMLSourceCode]);
}

@end
