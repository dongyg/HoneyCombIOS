//
//  ViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AIHexagonView.h"
#import "WSCoachMarksView.h"

@interface HomeViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate> {
    ADBannerView *_iadBannerView;
    GADBannerView *_admobBannerView;
}

@property (weak, nonatomic) IBOutlet UILabel *labelLevel;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnGuide;
@property (weak, nonatomic) IBOutlet UIButton *btnChallenge;

@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;

- (IBAction)playTapped:(id)sender;
- (IBAction)guideTapped:(id)sender;
- (IBAction)scoreTapped:(id)sender;
- (IBAction)getMoreTapped:(id)sender;

@end

