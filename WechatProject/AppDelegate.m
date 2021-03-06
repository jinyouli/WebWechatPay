//
//  AppDelegate.m
//  WechatProject
//
//  Created by jinyou on 2017/7/20.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UITabBarController *tb = [[UITabBarController alloc] init];
    
    MainViewController *MainVC = [[MainViewController alloc] init];
    MainVC.tabBarItem.title = @"首页";
    [self setTabImage:MainVC selectImage:@"main@4x" unSelectImage:@"main_1@4x"];

    
    ViewController *productVC = [[ViewController alloc] init];
    productVC.tabBarItem.title = @"产品";
    [self setTabImage:productVC selectImage:@"join@4x" unSelectImage:@"join_1@4x"];
    
    JoinViewController *joinVC = [[JoinViewController alloc] init];
    joinVC.tabBarItem.title = @"加入久久";
    [self setTabImage:joinVC selectImage:@"join@4x" unSelectImage:@"join_1@4x"];
    
    AgenceViewController *agenceVC = [[AgenceViewController alloc] init];
    agenceVC.tabBarItem.title = @"成为代理";
    [self setTabImage:agenceVC selectImage:@"agence@4x" unSelectImage:@"agence_1@4x"];
    
    MyInfoViewController *infoVC = [[MyInfoViewController alloc] init];
    infoVC.tabBarItem.title = @"我";
    [self setTabImage:infoVC selectImage:@"me@4x" unSelectImage:@"me_1@4x"];
    
    tb.viewControllers=@[MainVC,productVC,joinVC,agenceVC,infoVC];
    
    [self.window setRootViewController:tb];
    [self.window makeKeyAndVisible];
    
    [WXApi registerApp:@"wxf95d96900076001d"];
    return YES;
}

//设置tab图标
- (void)setTabImage:(UIViewController *)vc selectImage:(NSString *)selectImage unSelectImage:(NSString *)unselectImage
{
    if (IOS_7) {
        NSString *mainPath = [[NSBundle mainBundle] pathForResource:unselectImage ofType:@"png"];
        UIImage *imgMain = [UIImage imageWithContentsOfFile:mainPath];
        vc.tabBarItem.image = [imgMain imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NSString *main_select_path = [[NSBundle mainBundle] pathForResource:selectImage ofType:@"png"];
        UIImage *imgMain_select = [UIImage imageWithContentsOfFile:main_select_path];
        vc.tabBarItem.selectedImage = [imgMain_select imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        [vc.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",selectImage]] withFinishedUnselectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",unselectImage]]];
    }
}

//9.0前的方法，为了适配低版本 保留
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}

//9.0后的方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    //这里判断是否发起的请求为微信支付，如果是的话，用WXApi的方法调起微信客户端的支付页面（://pay 之前的那串字符串就是你的APPID，）
    return [WXApi handleOpenURL:url delegate:self];
}

//微信SDK自带的方法，处理从微信客户端完成操作后返回程序之后的回调方法,显示支付结果的
-(void) onResp:(BaseResp*)resp {
    //启动微信支付的response
    NSString *payResoult = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess:
                payResoult = @"支付结果：成功！";
            break;
            case WXErrCodeCommon:
                payResoult = @"支付结果：失败！";
            break;
            case WXErrCodeUserCancel:
                payResoult = @"用户已经退出支付！";
            break;
            default:
                payResoult = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WX_PaySuccess" object:payResoult];
    }
}

#pragma mark 微信支付方法
- (void)WXPay{
    //需要创建这个支付对象
    PayReq *req = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = @"";
    // 商家id，在注册的时候给的
    req.partnerId = @"";
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId = @"";
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package = @"";
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr = @"";
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp = @"";
    req.timeStamp = stamp.intValue;
    // 这个签名也是后台做的
    req.sign = @"";
    //发送请求到微信，等待微信返回onResp
    [WXApi sendReq:req];
}



@end
