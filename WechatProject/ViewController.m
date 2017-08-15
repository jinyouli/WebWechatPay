//
//  ViewController.m
//  WechatProject
//
//  Created by jinyou on 2017/7/20.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong)MBProgressHUD *progressHud;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURL *url = [NSURL URLWithString:@"http://99y.wy-8.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.label.text = @"加载中";
    [self.progressHud showAnimated:YES];
    
    [self.view addSubview:self.progressHud];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSDictionary *requestHeaders = request.allHTTPHeaderFields;
    
    if (!requestHeaders[@"client-type"]) {
        
        [mutableRequest setValue:@"jjy-ios" forHTTPHeaderField:@"client-type"];
        request = [mutableRequest copy];
        
        [webView loadRequest:request];
        return NO;
    }
    
    return YES;
}

- (void)wechatPay:(NSDictionary*)payDict
{
    PayReq *request = [[PayReq alloc] init];
    
    NSDictionary *wxpayDict = payDict[@"data"][@"wxpay"];
    
    request.partnerId = wxpayDict[@"partnerid"];
    request.prepayId = wxpayDict[@"prepayid"];
    request.package = wxpayDict[@"package"];
    request.nonceStr = wxpayDict[@"noncestr"];
    request.timeStamp = [wxpayDict[@"timestamp"] intValue];
    request.sign= wxpayDict[@"sign"];

    [WXApi sendReq:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.progressHud hideAnimated:YES];
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"jjy"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

- (void)getCall:(NSDictionary *)callDict{
    
    NSLog(@"Get:%@", callDict);
    
    [self wechatPay:callDict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
