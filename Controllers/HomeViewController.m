//
//  ViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "HomeViewController.h"
#import "WalkingViewController.h"
#import "GuideViewController.h"
#import "ScoreViewController.h"
#import "SettingViewController.h"
#import "UIButton+Bootstrap.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([self iAdTimeZoneSupported]) {
        NSLog(@"iAd");
        _iadBannerView = [[ADBannerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
        _iadBannerView.delegate = self;
        [_iadBannerView setBackgroundColor:[UIColor clearColor]];
        _iadBannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview: _iadBannerView];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeBottom constant:0];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeLeading constant:0];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeTrailing constant:0];
    } else {
        NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
        //_admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        _admobBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
        _admobBannerView.adUnitID = GOOGLE_ADMOB_UNITID;
        _admobBannerView.rootViewController = self;
        [_admobBannerView loadRequest:[GADRequest request]];
        [_admobBannerView setDelegate:self];
        [self.view addSubview:_admobBannerView];
        [self setEdge:self.view view:_admobBannerView attr:NSLayoutAttributeBottom constant:0];
        [self setEdge:self.view view:_admobBannerView attr:NSLayoutAttributeLeading constant:0];
        [self setEdge:self.view view:_admobBannerView attr:NSLayoutAttributeTrailing constant:0];
    }
    //
    [self.view setBackgroundColor:COLOR_BACKGROUND];
    [self.btnPlay infoStyle];
    [self.btnPlay addAwesomeIcon:FAIconPlay beforeTitle:YES];
    [self.btnGuide infoStyle];
    [self.btnGuide addAwesomeIcon:FAIconBook beforeTitle:YES];
    [self.btnChallenge infoStyle];
    [self.btnChallenge addAwesomeIcon:FAIconTrophy beforeTitle:YES];

    [self.btnScore warningStyle];
    [self.btnScore addAwesomeIcon:FAIconSignal beforeTitle:NO];
    [self.btnSetting warningStyle];
    [self.btnSetting addAwesomeIcon:FAIconCog beforeTitle:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
//    BOOL notFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"NotFirstRun"];
//    if (!notFirstRun) {
//        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"NotFirstRun"];
//        [self guideTapped:nil];
//    }
    //
    BOOL coachMarksShownWalk = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownWalkingView"];
    BOOL coachMarksShownHome = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownHome"];
    if (coachMarksShownWalk && !coachMarksShownHome) {
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnGuide.frame],
                                    @"caption": NSLocalizedString(@"HomeTip1", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnChallenge.frame],
                                    @"caption": NSLocalizedString(@"HomeTip2", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnScore.frame],
                                    @"caption": NSLocalizedString(@"HomeTip3", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnSetting.frame],
                                    @"caption": NSLocalizedString(@"HomeTip4", nil)
                                    }
                                ];
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        coachMarksView.animationDuration = 0.3;
        [self.view addSubview:coachMarksView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShownHome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [coachMarksView start];
    }
    //
    NSInteger currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentLevel"];
    NSInteger currentStage = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentStage"];
    if (!currentLevel) {
        currentLevel = 1;
    }
    if (!currentStage) {
        currentStage = 1;
    }
    self.labelLevel.text = [NSString stringWithFormat:@"%d - %d",(int)currentLevel,(int)currentStage];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)playTapped:(id)sender {
    WalkingViewController *view = [[WalkingViewController alloc] init];
    view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    view.MazeData = @"";
    view.IsChallenge = NO;
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)guideTapped:(id)sender {
//    GuideViewController *view = [[GuideViewController alloc] init];
//    view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:view animated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WSCoachMarksShownWalkingView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self playTapped:nil];
}

- (IBAction)scoreTapped:(id)sender {
}

- (IBAction)getMoreTapped:(id)sender {
}

//设置Autolayout中的边距辅助方法
- (void)setEdge:(UIView*)superview view:(UIView*)view attr:(NSLayoutAttribute)attr constant:(CGFloat)constant
{
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:attr relatedBy:NSLayoutRelationEqual toItem:superview attribute:attr multiplier:1.0 constant:constant]];
}

- (BOOL)iAdTimeZoneSupported {
    NSString *myTimeZone = [NSTimeZone localTimeZone].name;
    NSLog(@"TimeZone: %@",myTimeZone);
    NSArray *iAdTimeZones = [STRING_IAD_SUPPORT_ZONE componentsSeparatedByString:@";"];
    for (int i=0; i<iAdTimeZones.count; i++) {
        if ([myTimeZone hasPrefix:iAdTimeZones[i]]) {
            return true;
        }
    }
    return false;
}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Ad load error: %@", [error localizedDescription]);
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
}

#pragma mark - GADBannerViewDelegate

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidDismissScreen");
}

@end
