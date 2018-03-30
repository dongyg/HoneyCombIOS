//
//  qqApiDelegate.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/4/25.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "QQApiDelegate.h"
#import "SqliteDatabase.h"

@implementation QQApiDelegate

#pragma mark - QQApiInterfaceDelegate

-(void)onReq:(QQBaseReq *)req
{
    
}

-(void)onResp:(QQBaseResp *)resp
{
    //NSLog(@"%@ %@",resp.result,resp.description);
    //成功分享resp.result为0
    if([resp.result isEqualToString:@"0"]) {
        NSString* summary = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShareSummary"];
        int num = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShareNumber"] intValue];
        if (summary && num>0) {
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

-(void)isOnlineResponse:(NSDictionary *)response
{
    
}

@end
