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
    
    //self.progressHud.delegate = self;
    [self.view addSubview:self.progressHud];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *strUrl = [url absoluteString];
    
//    if ([strUrl hasPrefix:@"https://wappaygw.alipay.com/"]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"消息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return NO;
//    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSDictionary *requestHeaders = request.allHTTPHeaderFields;
    
    NSLog(@"头部==%@",requestHeaders);
    if (requestHeaders[@"client-type"]) {
        
        return YES;
        
    } else {
        
        [mutableRequest setValue:@"jjy-ios" forHTTPHeaderField:@"client-type"];
        request = [mutableRequest copy];
        
        [webView loadRequest:request];
        return YES;
    }
    
    return YES;
}

- (void)wechatPay
{
    PayReq *request = [[PayReq alloc] init];
    
    request.partnerId = @"1486723942";
    request.prepayId = @"wx20170814093300d32c2d9fe10322744508";
    request.package = @"Sign-WXPay";
    request.nonceStr = @"2y4qfukhsj9wz4lyhh9nifoltsjkpeay";
    request.timeStamp = 1502674333;
    request.sign= @"5018B102D72CBC9693E8AC2183B572DA";
    
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

- (void)getCall:(NSString *)callString{
    NSLog(@"Get:%@", callString);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //[self wechatPay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
