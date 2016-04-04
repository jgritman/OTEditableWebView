//
//  ViewController.m
//  EditableWebView
//
//  Created by openthread on 3/30/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "ViewController.h"
#import "UIWebView+OTEditableWebView.h"

@interface ViewController () <UIWebViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIButton *toggleEditableButton;
@property (nonatomic, strong) UIButton *logHTMLSourceCodeButton;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController

- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
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
    [self.logHTMLSourceCodeButton addTarget:self action:@selector(logHTMLSourceCode) forControlEvents:UIControlEventTouchUpInside];
    [self.logHTMLSourceCodeButton setTitle:@"Log Source Code" forState:UIControlStateNormal];
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
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.toggleEditableButton.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.toggleEditableButton.frame));
}

- (void)loadTestContent
{
    NSString *urlString = @"https://www.google.com";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)toggleEditable
{
    self.webView.bodyContentEditable = !self.webView.bodyContentEditable;
    NSLog(@"%d", self.webView.bodyContentEditable);

    //get content editable callback
    if (self.webView.bodyContentEditable)
    {
        __weak typeof(self) weakSelf = self;
        [self.webView setContentInputCallback:^(JSValue *msg){
            NSLog(@"editing msg: %@", msg);
            NSLog(@"%f", weakSelf.webView.bodyContentHeight);
        }];
    }
    else
    {
        [self.webView setContentInputCallback:nil];
    }
}

- (void)logHTMLSourceCode
{
    NSLog(@"Selection rect: %@", NSStringFromCGRect([self.webView selectionRectInWebView]));
    NSLog(@"%@", [self.webView allHTMLSourceCode]);
//    NSLog(@"%@", [self.webView bodySourceCode]);
//    NSLog(@"%@", [self.webView bodyInnerHTMLSourceCode]);
}

@end
