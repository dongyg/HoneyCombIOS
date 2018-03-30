//
//  AppDelegate.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "QQApiDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SKPaymentTransactionObserver, WXApiDelegate, TencentSessionDelegate> {
    TencentOAuth* _tencentOAuth;
    QQApiDelegate* _qqApiDelegate;
}

@property (strong, nonatomic) UIWindow *window;


@end

