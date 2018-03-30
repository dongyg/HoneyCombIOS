//
//  AppDelegate.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "AppDelegate.h"
#import "SqliteDatabase.h"
#import "Consts.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *strName = [[UIDevice currentDevice] name];
    NSLog(@"设备名称：%@", strName);
    //添回自己作为交易观察者对象
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104543084" andDelegate:self];
    _qqApiDelegate = [[QQApiDelegate alloc] init];
    //
    [WXApi registerApp:STRING_OPEN_WEIXIN];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"timeSuspend" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"timeResume" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"timeResume" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"timeSuspend" object:nil];
    // Remove the observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch ( transaction.transactionState ) {
            case SKPaymentTransactionStatePurchased: //交易完成
                //交易处理
                NSLog(@"交易: %@",transaction.payment.productIdentifier);
                int beyeBuy = 0;
                if ([transaction.payment.productIdentifier isEqual:@"honeycomb.beyes.1"]) {
                    beyeBuy = 100;
                } else if ([transaction.payment.productIdentifier isEqual:@"honeycomb.beyes.3"]) {
                    beyeBuy = 300;
                } else if ([transaction.payment.productIdentifier isEqual:@"honeycomb.beyes.6"]) {
                    beyeBuy = 600;
                } else if ([transaction.payment.productIdentifier isEqual:@"honeycomb.beyes12"]) {
                    beyeBuy = 1200;
                } else {
                    NSString * str = transaction.payment.productIdentifier;
                    str = [str stringByReplacingOccurrencesOfString:@"honeycomb.beyes." withString:@""];
                    str = [str stringByReplacingOccurrencesOfString:@"honeycomb.beyes" withString:@""];
                    NSScanner* scan = [NSScanner scannerWithString:str];
                    int val;
                    if ([scan scanInt:&val] && [scan isAtEnd]) {
                        beyeBuy = [str intValue] * 100;
                    }
                }
                if (beyeBuy > 0) {
                    [[SqliteDatabase database] UpdateBeeEyeNumber:beyeBuy summary:NSLocalizedString(STRING_BEYE_PUCHASE,nil)];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"purchaseDone" object:nil];
                }
                //移除付款队列
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                //[self.navigationController popViewControllerAnimated:YES];
                break;
            case SKPaymentTransactionStateFailed: //交易失败
                //NSLog(@"交易失败");
                break;
            case SKPaymentTransactionStateRestored: //交易恢复
                //NSLog(@"交易恢复");
                break;
            default:
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"handleOpenURL: %@",url);
    NSString* surl = [url absoluteString];
    if ([surl hasPrefix:STRING_OPEN_WEIXIN]) {
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([surl hasPrefix:STRING_OPEN_TENCENT]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return false;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"openURL: %@ %@",url,sourceApplication);
    NSString* surl = [url absoluteString];
    if ([surl hasPrefix:STRING_OPEN_WEIXIN]) {
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([surl hasPrefix:STRING_OPEN_TENCENT]) {
        [QQApiInterface handleOpenURL:url delegate:_qqApiDelegate];
        return [TencentOAuth HandleOpenURL:url];
    }
    return false;
}

#pragma mark - weixin

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        NSString* summary = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShareSummary"];
        int num = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShareNumber"] intValue];
        if (resp.errCode==WXSuccess && summary && num>0) {
            NSString* sharesuccess = num>10 ? @"ShareSuccessOnce" : @"ShareSuccessStage";
            int setnum = [[SqliteDatabase database] UpdateBeeEyeNumber:num summary:summary];
            if (setnum>0) {
                if (setnum>10) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"purchaseDone" object:nil];
                }
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Share",nil)
                                          message:NSLocalizedString(sharesuccess,nil)
                                          delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ShareSummary"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ShareNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - tencent

- (void)tencentDidLogin
{
    
}
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}
- (void)tencentDidLogout
{
    
}
- (void)tencentDidNotNetWork
{
    
}

@end
