//
//  SpinnerFactory.m
//  Demos
//
//  Created by Yigung Dong on 13-9-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SpinnerFactory.h"
#import "SpinnerHeader.h"

@implementation SpinnerFactory

+(void)EnterWaiting:(UIView *)view
{
    if (!spinnerView) {
        CGFloat width = view.bounds.size.width/2;
        CGFloat height = view.bounds.size.height/2;
        CGRect rect = CGRectMake(width/2,height/2,width,width);
        spinnerView = [[UIView alloc] initWithFrame:rect];
        //设置阴影需要导入QuartzCore
        spinnerView.layer.shadowOffset = CGSizeMake(3, 3);
        spinnerView.layer.shadowRadius = 5.0;
        spinnerView.layer.shadowColor = [UIColor blackColor].CGColor;
        spinnerView.layer.cornerRadius = 5.0f;
        [spinnerView setTag:999];
        [spinnerView setBackgroundColor:[UIColor blackColor]];
        [spinnerView setAlpha:0.4];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect frame = spinner.frame;
        frame.origin.x = spinnerView.frame.size.width / 2 - frame.size.width / 2;
        frame.origin.y = spinnerView.frame.size.height / 2 - frame.size.height / 2;
        spinner.frame = frame;
        [spinnerView addSubview:spinner];
        [spinner startAnimating];
    }
    [view addSubview:spinnerView];
    //[[NSRunLoop mainRunLoop] runUntilDate:nil];
}

+(void)LeaveWaiting:(UIView *)view
{
    if (spinnerView) {
        [spinnerView removeFromSuperview];
    }
}

@end
