//
//  ViewController.h
//  WechatProject
//
//  Created by jinyou on 2017/7/20.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjcDelegate <JSExport>
- (void)call;
- (void)getCall:(NSDictionary *)callDict;

@end

@interface ViewController : UIViewController<JSObjcDelegate>
@property (nonatomic, strong) JSContext *jsContext;

@end

