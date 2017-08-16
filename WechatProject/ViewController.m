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

@property (nonatomic,copy) NSString *returnUrl;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payReturn:) name:@"WX_PaySuccess" object:nil];
}

- (void)payReturn:(NSNotification *)notif
{
    //http://99y.wy-8.com/trade/index.php?m=myorder&a=info&id=176
    
    NSURL *url;
    if (![self.returnUrl isEqualToString:@""]) {
        url = [NSURL URLWithString:self.returnUrl];
    }else{
        url = [NSURL URLWithString:@"http://99y.wy-8.com/index.php?m=center"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    NSString *msg = notif.object;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *strUrl = [url absoluteString];
    NSLog(@"连接==%@",strUrl);
    
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
    self.returnUrl = payDict[@"data"][@"order_detail_url"];
    
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
