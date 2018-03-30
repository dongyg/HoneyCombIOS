//
//  WalkingViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "WalkingViewController.h"
#import "UIButton+Bootstrap.h"
#import "MazeViewController.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "QQSessionActivity.h"
#import "QQZoneActivity.h"

@interface WalkingViewController ()

@end

@implementation WalkingViewController
@synthesize MazeData = _MazeData;
@synthesize IsChallenge = _IsChallenge;
@synthesize ChallengeId = _ChallengeId;
@synthesize ChallengeName = _ChallengeName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"stages.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    _jsonStages =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timeSuspend) name:@"timeSuspend" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timeResume) name:@"timeResume" object:nil];
    _openBeeEyes = [[NSUserDefaults standardUserDefaults] boolForKey:@"OpenBeeEyes"];
    _database = [SqliteDatabase database];
    _beyeRetain = [_database getBeeEyeRetain];
    _beyedynamic = _beyeRetain;
    //
    UIDevice *device = [UIDevice currentDevice];
    if (device.orientation==UIDeviceOrientationLandscapeLeft || device.orientation==UIDeviceOrientationLandscapeRight) {
        _Length = MIN(self.view.frame.size.width, self.view.frame.size.height) * 0.67/3/sqrt(3);
    } else {
        _Length = MIN(self.view.frame.size.width, self.view.frame.size.height) * 0.8/3/sqrt(3);
    }
    _xCenter = self.view.frame.size.width/2;
    _yCenter = self.view.frame.size.height/2; // + _Length/2;
    //
    if ([self iAdTimeZoneSupported]) {
        _iadBannerView = [[ADBannerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
        _iadBannerView.delegate = self;
        [_iadBannerView setBackgroundColor:[UIColor clearColor]];
        _iadBannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview: _iadBannerView];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeBottom constant:0];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeLeading constant:0];
        [self setEdge:self.view view:_iadBannerView attr:NSLayoutAttributeTrailing constant:0];
    } else {
        //NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
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
    _btnMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnMenu setFrame:CGRectMake(20, 30, 40, 40)];
    [_btnMenu addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [_btnMenu setTitle:@"" forState:UIControlStateNormal];
    [_btnMenu warningStyle];
    [_btnMenu addAwesomeIcon:FAIconArrowLeft beforeTitle:NO];
    _btnMenu.hidden = NO; //self.IsChallenge;
    [self.view addSubview:_btnMenu];
    //
    _labelStars = [[UILabel alloc] initWithFrame:CGRectMake(20,70,95,30)];
    _labelStars.textAlignment = NSTextAlignmentLeft;
    _labelStars.font = [UIFont systemFontOfSize:20];
    UIFont * fontTwo = [UIFont fontWithName:@"FontAwesome" size:20];
    [_labelStars setTextColor:[UIColor orangeColor]];
    [_labelStars setFont:fontTwo];
    NSString *iconString = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
    [_labelStars setText:[NSString stringWithFormat:@"%@%@%@%@",iconString,iconString,iconString,iconString]];
    [self.view addSubview:_labelStars];
    //
    _btnRenewGame = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnRenewGame setFrame:CGRectMake(20, 100, 40, 40)];
    [_btnRenewGame addTarget:self action:@selector(clickReNewGame) forControlEvents:UIControlEventTouchUpInside];
    [_btnRenewGame setTitle:@"" forState:UIControlStateNormal];
    [_btnRenewGame addAwesomeIcon:FAIconRefresh beforeTitle:NO];
    _btnRenewGame.hidden = self.IsChallenge;
    [_btnRenewGame defaultStyle];
    [self.view addSubview:_btnRenewGame];
    //
    _labelLevel = [[UILabel alloc] initWithFrame:CGRectMake(70,39,self.view.frame.size.width-140,21)];
    _labelLevel.textAlignment = NSTextAlignmentCenter;
    _labelLevel.font = [UIFont systemFontOfSize:20];
    _labelLevel.hidden = NO; //self.IsChallenge;
    [self.view addSubview:_labelLevel];
    //
    _timerLabel = [[MZTimerLabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 70, 100, 20)];
    _timerLabel.timerType = MZTimerLabelTypeStopWatch;
    [self.view addSubview:_timerLabel];
    _timerLabel.timeLabel.backgroundColor = [UIColor clearColor];
    _timerLabel.timeLabel.textColor = [UIColor brownColor];
    _timerLabel.timeLabel.textAlignment = NSTextAlignmentCenter;
    _timerLabel.timeFormat = @"HH:mm:ss.SS";
    //
    _labelSteps = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 90, 100, 20)];
    [self.view addSubview:_labelSteps];
    _labelSteps.backgroundColor = [UIColor clearColor];
    _labelSteps.textColor = [UIColor brownColor];
    _labelSteps.textAlignment = NSTextAlignmentCenter;
    //
    _btnViewMaze = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnViewMaze setFrame:CGRectMake(self.view.frame.size.width-60, 100, 40, 40)];
    [_btnViewMaze addTarget:self action:@selector(clickViewMaze) forControlEvents:UIControlEventTouchUpInside];
    [_btnViewMaze setTitle:@"" forState:UIControlStateNormal];
    [_btnViewMaze defaultStyle];
    [_btnViewMaze addAwesomeIcon:FAIconGlobe beforeTitle:NO];
    [self.view addSubview:_btnViewMaze];
    //
    _labelBeyeNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 70, 40, 20)];
    _labelBeyeNumber.backgroundColor = [UIColor clearColor];
    _labelBeyeNumber.textColor = [UIColor brownColor];
    _labelBeyeNumber.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelBeyeNumber];
    [self showBeeEyesNumber];
    _btnSwitchBeye = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnSwitchBeye setFrame:CGRectMake(self.view.frame.size.width-60, 30, 40, 40)];
    [_btnSwitchBeye addTarget:self action:@selector(clickSwitchBeye) forControlEvents:UIControlEventTouchUpInside];
    [_btnSwitchBeye setTitle:@"" forState:UIControlStateNormal];
    [_btnSwitchBeye warningStyle];
    //_btnSwitchBeye.hidden = YES;
    if (_openBeeEyes) {
        [_btnSwitchBeye setAwesomeIcon:FAIconEyeOpen beforeTitle:NO];
    } else {
        [_btnSwitchBeye setAwesomeIcon:FAIconEyeClose beforeTitle:NO];
    }
    [self.view addSubview:_btnSwitchBeye];
    //
    _labelMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, _yCenter+_Length*5/2+3, self.view.frame.size.width-40, 20)];
    _labelMessage.textAlignment = NSTextAlignmentCenter;
    _labelMessage.font = [UIFont systemFontOfSize:10];
    _labelMessage.hidden = !SWITCH_DEBUG;;
    if (self.IsChallenge) {
        _labelMessage.text = NSLocalizedString(@"TipMissStarChallenge",nil);
    } else {
        _labelMessage.text = NSLocalizedString(@"TipMissStarGame",nil);
    }
    [self.view addSubview:_labelMessage];
    //
    _btnNewGame = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnNewGame setFrame:CGRectMake(20, _yCenter+_Length*5/2+25, _xCenter-30, 40)];
    [_btnNewGame addTarget:self action:@selector(clickNewGame) forControlEvents:UIControlEventTouchUpInside];
    [_btnNewGame infoStyle];
    if (self.IsChallenge) {
        [_btnNewGame setTitle:NSLocalizedString(@"End Challenge",nil) forState:UIControlStateNormal];
        [_btnNewGame addAwesomeIcon:FAIconArrowLeft beforeTitle:YES];
    } else {
        [_btnNewGame setTitle:NSLocalizedString(@"New Game",nil) forState:UIControlStateNormal];
        [_btnNewGame addAwesomeIcon:FAIconPlay beforeTitle:YES];
    }
    _btnNewGame.hidden = !SWITCH_DEBUG;;
    [self.view addSubview:_btnNewGame];
    //
    _btnShare = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnShare setFrame:CGRectMake(_xCenter+10, _yCenter+_Length*5/2+25, _xCenter-30, 40)];
    [_btnShare addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
    [_btnShare infoStyle];
    [_btnShare setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [_btnShare addAwesomeIcon:FAIconShare beforeTitle:YES];
    _btnShare.hidden = !SWITCH_DEBUG;;
    [self.view addSubview:_btnShare];
    //
    [self.view setBackgroundColor:COLOR_BACKGROUND];
    [self initGame];
    //
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownWalkingView"];
    if (!coachMarksShown) {
        // Setup coach marks
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelLevel.frame],
                                    @"caption": NSLocalizedString(@"WalkTip0", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.frame],
                                    @"caption": NSLocalizedString(@"WalkTip1", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room2.frame],
                                    @"caption": NSLocalizedString(@"WalkTip2", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnSwitchBeye.frame],
                                    @"caption": NSLocalizedString(@"WalkTip3", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelBeyeNumber.frame],
                                    @"caption": NSLocalizedString(@"WalkTip4", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_timerLabel.frame],
                                    @"caption": NSLocalizedString(@"WalkTip5", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelSteps.frame],
                                    @"caption": NSLocalizedString(@"WalkTip6", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelStars.frame],
                                    @"caption": NSLocalizedString(@"WalkTip7", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnRenewGame.frame],
                                    @"caption": NSLocalizedString(@"WalkTip8", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnViewMaze.frame],
                                    @"caption": NSLocalizedString(@"WalkTip9", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnMenu.frame],
                                    @"caption": NSLocalizedString(@"WalkTip10", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room1.frame],
                                    @"caption": NSLocalizedString(@"WalkTip11", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room0.frame],
                                    @"caption": NSLocalizedString(@"WalkTip12", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.frame],
                                    @"caption": NSLocalizedString(@"WalkTip13", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelStars.frame],
                                    @"caption": NSLocalizedString(@"WalkTip14", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelMessage.frame],
                                    @"caption": NSLocalizedString(@"WalkTip15", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnNewGame.frame],
                                    @"caption": NSLocalizedString(@"WalkTip16", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room5.frame],
                                    @"caption": NSLocalizedString(@"WalkTip17", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room2.frame],
                                    @"caption": NSLocalizedString(@"WalkTip18", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_labelStars.frame],
                                    @"caption": NSLocalizedString(@"WalkTip19", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.room0.frame],
                                    @"caption": NSLocalizedString(@"WalkTip20", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_centerRoomView.frame],
                                    @"caption": NSLocalizedString(@"WalkTip21", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnShare.frame],
                                    @"caption": NSLocalizedString(@"WalkTip22", nil)
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnMenu.frame],
                                    @"caption": NSLocalizedString(@"WalkTip23", nil)
                                    }
                                ];
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        coachMarksView.delegate = self;
        [self.view addSubview:coachMarksView];
        _isGuide = YES;
        // Show coach marks
        [coachMarksView start];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_timerLabel.counting) {
        if (self.IsChallenge) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[_timerLabel getTimeCounted]] forKey:@"ChallengeSpentTime"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[_timerLabel getTimeCounted]] forKey:@"GameSpentTime"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //不支持除竖屏以外的方向，所以这个方法其实已经没有用了
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        _Length = MIN(self.view.frame.size.width, self.view.frame.size.height) * 0.67/3/sqrt(3);
    } else {
        _Length = MIN(self.view.frame.size.width, self.view.frame.size.height) * 0.8/3/sqrt(3);
    }
    _xCenter = self.view.frame.size.width/2;
    _yCenter = self.view.frame.size.height/2; // + _Length/2;
    [self ReDrawRooms];
}

- (void)timeSuspend {
    if (_timerLabel) {
        [_timerLabel pause];
    }
}
- (void)timeResume {
    if (_timerLabel && (_maze && abs(_currentRoomNo)!=_maze.RoomCount+1)) {
        [_timerLabel start];
    }
}
-(void)showBeeEyesNumber
{
    if (_beyedynamic>999) {
        _labelBeyeNumber.text = @"999+";
    } else {
        _labelBeyeNumber.text = [NSString stringWithFormat:@"%d",_beyedynamic];
    }
}

-(void)clickBackButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickViewMaze
{
    if (_timerLabel.counting) {
        if (_beyedynamic>=10) {
            MazeViewController *view = [[MazeViewController alloc] init];
            view.MazeData = self.MazeData;
            view.showRoomNumber = NO;
            view.showShareButton = NO;
            view.currentRoomNumber = abs(_currentRoomNo);
            view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:view animated:YES
                             completion:^(void){
                                 NSString* summary = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_GAMECONSUME,nil), NSLocalizedString(@"ViewMap",nil)];
                                 _beyeRetain = [_database getBeeEyeRetain];
                                 _beyedynamic = _beyedynamic-10;
                                 [_database UpdateBeeEyeNumber:-10 summary:summary];
                                 [self showBeeEyesNumber];
                             }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:NSLocalizedString(@"Bee-eyesNotEnough",nil)
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

-(void)clickShare
{
    MazeViewController *view = [[MazeViewController alloc] init];
    view.StarGot = _gotStars.count;
    view.StarTotal = _starRooms.count;
    view.MazeData = self.MazeData;
    view.showRoomNumber = NO;
    [view calcPoints];

    UIImage *imageToShare = [view getSnapshot:_timerLabel.timeLabel.text];

    NSString *postText = [NSString stringWithFormat:@"%@",NSLocalizedString(STRING_SHARETEXT,nil)];
    NSURL *urlToShare = [NSURL URLWithString:STRING_SHAREURL];
    NSArray *activityItems = @[postText, imageToShare, urlToShare];
    
    //    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    //    [imgView setImage:imageToShare];
    //    [self.view addSubview:imgView];
    
    //添加微信、QQ分享
    NSArray* activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init], [[QQSessionActivity alloc] init], [[QQZoneActivity alloc] init]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                             applicationActivities:activity];
    activityVC.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypeAddToReadingList, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, nil];
    
    if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
        activityVC.popoverPresentationController.sourceView = _btnShare;
        activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    [activityVC setCompletionHandler:^(NSString *act, BOOL done)
    {
        //NSString *ServiceMsg = nil;
        //if ( [act isEqualToString:UIActivityTypePostToWeibo] ) ServiceMsg = @ "SinaWeibo";
        if ( done && act ) {
            if ([act isEqualToString:@"WeixinTimelineActivity"] || [act isEqualToString:@"WeixinSessionActivity"] || [act isEqualToString:@"QQSessionActivity"] || [act isEqualToString:@"QQZoneActivity"]) {
                //微信、QQ分享需要等待返回
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_AWARD,nil),_labelLevel.text] forKey:@"ShareSummary"];
                [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"ShareNumber"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                //其他iOS系统内的完成后即为分享成功
                int setnum = [[SqliteDatabase database] UpdateBeeEyeNumber:10 summary:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_AWARD,nil),_labelLevel.text]];
                if (setnum>0) {
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:NSLocalizedString(@"Share",nil)
                                              message:NSLocalizedString(@"ShareSuccessStage",nil)
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                              otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            NSLog(@"Share Done. %@",act);
        } else {
            NSLog(@"Share Cancel. %@",act);
        }
    }];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void)clickReNewGame
{
    if (_timerLabel.counting && !self.IsChallenge) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tip",nil)
                                                       message:NSLocalizedString(@"RenewGame",nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                             otherButtonTitles:NSLocalizedString(@"OK",nil),nil ];
        [alert show];
    }
}

-(void)clickNewGame
{
    if (_timerLabel.counting) {
        [self saveAndClearPlayingData];
    }
    if (self.IsChallenge) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self clickBackButton];
        }
    } else {
        [self initGame];
    }
}

-(void)clickSwitchBeye
{
    if (!_timerLabel.counting) return;
    _openBeeEyes = !_openBeeEyes;
    [[NSUserDefaults standardUserDefaults] setBool:_openBeeEyes forKey:@"OpenBeeEyes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (_openBeeEyes) {
        [_btnSwitchBeye setAwesomeIcon:FAIconEyeOpen beforeTitle:NO];
        [self updateBeeEyesRooms];
    } else {
        [_btnSwitchBeye setAwesomeIcon:FAIconEyeClose beforeTitle:NO];
    }
}

-(void)saveAndClearPlayingData
{
    [_timerLabel pause];
    NSTimeInterval spentTime = [_timerLabel getTimeCounted];
    if (self.IsChallenge) {
        if (!_isGuide) {
            [_database AddChallengeScore:_ChallengeId cname:_ChallengeName spentTime:spentTime starCount:_gotStars.count mazeData:self.MazeData steps:[_steps componentsJoinedByString:@""]];
            int setnum = [_database UpdateBeeEyeNumber:10 summary:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_GAMEGIFT,nil), _ChallengeName]];
            if (setnum>0) {
                _beyeRetain = _beyeRetain+setnum;
                _beyedynamic = _beyedynamic+setnum;
                [self showBeeEyesNumber];
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeRoomNo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeSpentTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeGotStars"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeSteps"];
    } else {
        NSInteger currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentLevel"];
        NSInteger currentStage = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentStage"];
        if (!currentLevel) {
            currentLevel = 1;
        }
        if (!currentStage) {
            currentStage = 1;
        }
        //
        if (!_isGuide) {
            [_database AddGameScore:(int)currentLevel stage:(int)currentStage spentTime:spentTime starCount:_gotStars.count mazeData:self.MazeData steps:[_steps componentsJoinedByString:@""]];
            int setnum = [_database UpdateBeeEyeNumber:10 summary:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_GAMEGIFT,nil), _labelLevel.text]];
            if (setnum>0) {
                _beyeRetain = _beyeRetain+setnum;
                _beyedynamic = _beyedynamic+setnum;
                [self showBeeEyesNumber];
            }
            if (currentStage>=9) {
                currentLevel = currentLevel+1;
                currentStage = 1;
            } else {
                currentStage = currentStage+1;
            }
        }
        [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:@"CurrentLevel"];
        [[NSUserDefaults standardUserDefaults] setInteger:currentStage forKey:@"CurrentStage"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CacheMaze"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameRoomNo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSpentTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameGotStars"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSteps"];
    }
    if (_beyesRooms.count>0) {
        NSString *summary = @"";
        if (_IsChallenge) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeBeeEyesRooms"];
            summary = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_GAMECONSUME,nil), _ChallengeName];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameBeeEyesRooms"];
            summary = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_GAMECONSUME,nil), _labelLevel.text];
        }
        [_database UpdateBeeEyeNumber:-_consumeBeyes summary:summary];
        _consumeBeyes = 0;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Internal

-(void)initGame {
    _isGuide = NO;
    int currentLevel = 1;
    int currentStage = 1;
    _btnNewGame.hidden = !SWITCH_DEBUG;
    _btnShare.hidden = !SWITCH_DEBUG;
    _labelMessage.hidden = !SWITCH_DEBUG;
    NSString *spentTime;
    _beyeRetain = [_database getBeeEyeRetain];
    _beyedynamic = _beyeRetain;
    if (self.IsChallenge) {
        //NSLog(@"Challenge MazeData: %@",self.MazeData);
        if (self.navigationController && self.navigationItem) {
            self.navigationItem.title = _ChallengeName;
        } else {
            _labelLevel.text = _ChallengeName;
        }
        NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeId"];
        if ([_ChallengeId isEqualToString:cid]) {
            _currentRoomNo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeRoomNo"] intValue];
            spentTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeSpentTime"];
            NSMutableArray *arrGotStars = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeGotStars"];
            _gotStars = [[NSMutableArray alloc] initWithArray:arrGotStars];
            //读已走步
            NSMutableArray *arrSteps = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeSteps"];
            _steps = [[NSMutableArray alloc] initWithArray:arrSteps];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:_ChallengeId forKey:@"ChallengeId"];
            _currentRoomNo = -INT_ENTRYROOM;
            spentTime = 0;
            //初始化步数数组
            _steps = [[NSMutableArray alloc] init];
        }
        //读取beyes缓存
        NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeBeeEyesRooms"];
        _beyesRooms = [[NSMutableSet alloc] initWithArray:arrTemp];
        _consumeBeyes = _beyesRooms.count;
        if (_beyedynamic<_consumeBeyes) {
            _consumeBeyes = 0;
            [_beyesRooms removeAllObjects];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeBeeEyesRooms"];
        }
    } else {
        //读关卡值
        currentLevel = [[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentLevel"] intValue];
        currentStage = [[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentStage"] intValue];
        if (!currentLevel) {
            currentLevel = 1;
        }
        if (!currentStage) {
            currentStage = 1;
        }
        _labelLevel.text = [NSString stringWithFormat:@"%d - %d",currentLevel,currentStage];
        //加载关卡数据
        BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownWalkingView"];
        if (!coachMarksShown) {
            self.MazeData = @"{\"Level\":\"2\",\"StartRoom\":\"1\",\"EntryDoor\":\"3\",\"Path\":\"10\",\"Traps\":{\"2\":\"2\"},\"Stars\":[\"5\"]}";
            _currentRoomNo = -INT_ENTRYROOM;
            spentTime = 0;
            _gotStars = [[NSMutableArray alloc] init];
            _beyesRooms = [[NSMutableSet alloc] init];
            _consumeBeyes = 0;
            _steps = [[NSMutableArray alloc] init];
        } else {
            self.MazeData = [HoneyComb getJsonString:[_jsonStages objectForKey:_labelLevel.text]];
            if (!self.MazeData) {
                self.MazeData = [[NSUserDefaults standardUserDefaults] objectForKey:@"CacheMaze"];
            }
            _currentRoomNo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GameRoomNo"] intValue];
            spentTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameSpentTime"];
            NSMutableArray *arrGotStars = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameGotStars"];
            _gotStars = [[NSMutableArray alloc] initWithArray:arrGotStars];
            //NSLog(@"Load MazeData: %@",self.MazeData);
            //读取beyes缓存
            NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameBeeEyesRooms"];
            _beyesRooms = [[NSMutableSet alloc] initWithArray:arrTemp];
            _consumeBeyes = _beyesRooms.count;
            if (_beyedynamic<_consumeBeyes) {
                _consumeBeyes = 0;
                [_beyesRooms removeAllObjects];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameBeeEyesRooms"];
            }
            //读已走步
            NSMutableArray *arrSteps = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameSteps"];
            _steps = [[NSMutableArray alloc] initWithArray:arrSteps];
        }
    }
    _beyedynamic = _beyedynamic - _consumeBeyes;
    [self showBeeEyesNumber];
    //创建迷宫对象
    if (self.MazeData && ![self.MazeData isEqualToString:@""]) {
        _maze = [[HoneyComb alloc] initWithJsonData:self.MazeData];
    } else {
        _maze = [[HoneyComb alloc] init];
        [_maze setLevel:currentLevel+2];
        [_maze generateRoute];
        self.MazeData = [_maze getMazeJsonData];
        if (SWITCH_DEBUG) {
            NSLog(@"Save MazeData: %@",self.MazeData);
        }
        [[NSUserDefaults standardUserDefaults] setObject:[_maze getMazeJsonData] forKey:@"CacheMaze"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _currentRoomNo = -INT_ENTRYROOM;
    }
    _starRooms = [[NSMutableArray alloc] initWithArray:[_maze StarRooms]];
    if (!_gotStars) {
        _gotStars = [[NSMutableArray alloc] init];
    }
    [self updateStarStatus:-9];
    if (_currentRoomNo==0) {
        _currentRoomNo = -INT_ENTRYROOM;
    }
    //
    [self drawRooms:_currentRoomNo fromDoor:-9];
    //
    [_timerLabel start];
    if (spentTime && self.MazeData) {
        [_timerLabel addTimeCountedByTime:[spentTime doubleValue]];
    } else {
        [_timerLabel reset];
    }
    //
    [self updateSteps];
}

-(void)ReDrawRooms {
    [self drawRooms:_currentRoomNo fromDoor:-9];
    [_labelLevel setFrame:CGRectMake(self.view.frame.size.width/2-50,39,100,21)];
    [_timerLabel setFrame:CGRectMake(self.view.frame.size.width/2-50, 70, 100, 20)];
    [_labelSteps setFrame:CGRectMake(self.view.frame.size.width/2-50, 100, 100, 20)];
    [_btnSwitchBeye setFrame:CGRectMake(self.view.frame.size.width-60, 30, 40, 40)];
    [_labelBeyeNumber setFrame:CGRectMake(self.view.frame.size.width-60, 70, 40, 20)];
    [_btnViewMaze setFrame:CGRectMake(self.view.frame.size.width-60, 90, 40, 40)];
    [_labelMessage setFrame:CGRectMake(20, _yCenter+_Length*5/2+3, self.view.frame.size.width-40, 20)];
    [_btnNewGame setFrame:CGRectMake(20, _yCenter+_Length*5/2+25, _xCenter-30, 40)];
    [_btnShare setFrame:CGRectMake(_xCenter+10, _yCenter+_Length*5/2+25, _xCenter-30, 40)];
}

-(void)drawRooms:(int)centerRoom fromDoor:(int)fromDoor {
//    NSLog(@"Tap room :%i, From door:%d",centerRoom,fromDoor);
    //-INT_ENTRYROOM代表入口前的虚拟房间；RoomCount-1代表出口的虚拟房间；其它代表普通房间（负的为可通，正的为不通）
    if ( centerRoom==0 || (abs(centerRoom)!=INT_ENTRYROOM && abs(centerRoom)>_maze.RoomCount+1) ) {
        NSLog(@"Invalid Room: %d",centerRoom);
        return;
    }
    NSMutableArray *_needRemoveRooms = [[NSMutableArray alloc] init]; //要移除的房间3个
    NSMutableArray *_newRooms = [[NSMutableArray alloc] init]; //新添加的房间3个
    NSMutableArray *_retainRooms = [[NSMutableArray alloc] init]; //保留的房间4个
    //保存当前中心房间编号，和房间对象
    _currentRoomNo = centerRoom;
    if (abs(centerRoom)==INT_ENTRYROOM) {
        _currentRoom = [_maze Room:0];
    } else {
        _currentRoom = [_maze Room:abs(centerRoom)];
    }
    int xMove = 0;
    int yMove = 0;
    AIHexagonView *nextCenterRoomView;
    //根据从哪个房间走进来决定画房间的偏移量；初始时无偏移量直接画在中间；需要移除的房间
    if (fromDoor==-9 && _centerRoomView) {
        [_needRemoveRooms addObject:_centerRoomView];
        [_needRemoveRooms addObject:_centerRoomView.room0];
        [_needRemoveRooms addObject:_centerRoomView.room1];
        [_needRemoveRooms addObject:_centerRoomView.room2];
        [_needRemoveRooms addObject:_centerRoomView.room3];
        [_needRemoveRooms addObject:_centerRoomView.room4];
        [_needRemoveRooms addObject:_centerRoomView.room5];
    } else if (fromDoor==0) {
        xMove = _Length*sqrt(3)/2;
        yMove = - _Length - _Length/2;
        [_needRemoveRooms addObject:_centerRoomView.room2];
        [_needRemoveRooms addObject:_centerRoomView.room4];
        [_needRemoveRooms addObject:_centerRoomView.room5];
        nextCenterRoomView = _centerRoomView.room0;
        nextCenterRoomView.room2 = _centerRoomView.room1;
        if (nextCenterRoomView.room2) { nextCenterRoomView.room2.FromDoor = 2; }
        nextCenterRoomView.room4 = _centerRoomView.room3;
        if (nextCenterRoomView.room4) { nextCenterRoomView.room4.FromDoor = 4; }
        nextCenterRoomView.room5 = _centerRoomView;
        if (nextCenterRoomView.room5) { nextCenterRoomView.room5.FromDoor = 5; }
        [_retainRooms addObject:_centerRoomView.room0];
        [_retainRooms addObject:_centerRoomView.room1];
        [_retainRooms addObject:_centerRoomView.room3];
        [_retainRooms addObject:_centerRoomView];
    } else if (fromDoor==1) {
        xMove = _Length*sqrt(3)/2*2;
        [_needRemoveRooms addObject:_centerRoomView.room3];
        [_needRemoveRooms addObject:_centerRoomView.room4];
        [_needRemoveRooms addObject:_centerRoomView.room5];
        nextCenterRoomView = _centerRoomView.room1;
        nextCenterRoomView.room3 = _centerRoomView.room0;
        if (nextCenterRoomView.room3) { nextCenterRoomView.room3.FromDoor = 3; }
        nextCenterRoomView.room4 = _centerRoomView;
        if (nextCenterRoomView.room4) { nextCenterRoomView.room4.FromDoor = 4; }
        nextCenterRoomView.room5 = _centerRoomView.room2;
        if (nextCenterRoomView.room5) { nextCenterRoomView.room5.FromDoor = 5; }
        [_retainRooms addObject:_centerRoomView.room0];
        [_retainRooms addObject:_centerRoomView.room1];
        [_retainRooms addObject:_centerRoomView.room2];
        [_retainRooms addObject:_centerRoomView];
    } else if (fromDoor==2) {
        xMove = _Length*sqrt(3)/2;
        yMove = _Length + _Length/2;
        [_needRemoveRooms addObject:_centerRoomView.room0];
        [_needRemoveRooms addObject:_centerRoomView.room3];
        [_needRemoveRooms addObject:_centerRoomView.room4];
        nextCenterRoomView = _centerRoomView.room2;
        nextCenterRoomView.room0 = _centerRoomView.room1;
        if (nextCenterRoomView.room0) { nextCenterRoomView.room0.FromDoor = 0; }
        nextCenterRoomView.room4 = _centerRoomView.room5;
        if (nextCenterRoomView.room4) { nextCenterRoomView.room4.FromDoor = 4; }
        nextCenterRoomView.room3 = _centerRoomView;
        if (nextCenterRoomView.room3) { nextCenterRoomView.room3.FromDoor = 3; }
        [_retainRooms addObject:_centerRoomView.room2];
        [_retainRooms addObject:_centerRoomView.room1];
        [_retainRooms addObject:_centerRoomView.room5];
        [_retainRooms addObject:_centerRoomView];
    } else if (fromDoor==3) {
        xMove = - _Length*sqrt(3)/2;
        yMove = - _Length - _Length/2;
        [_needRemoveRooms addObject:_centerRoomView.room1];
        [_needRemoveRooms addObject:_centerRoomView.room2];
        [_needRemoveRooms addObject:_centerRoomView.room5];
        nextCenterRoomView = _centerRoomView.room3;
        nextCenterRoomView.room1 = _centerRoomView.room0;
        if (nextCenterRoomView.room1) { nextCenterRoomView.room1.FromDoor = 1; }
        nextCenterRoomView.room5 = _centerRoomView.room4;
        if (nextCenterRoomView.room5) { nextCenterRoomView.room5.FromDoor = 5; }
        nextCenterRoomView.room2 = _centerRoomView;
        if (nextCenterRoomView.room2) { nextCenterRoomView.room2.FromDoor = 2; }
        [_retainRooms addObject:_centerRoomView.room0];
        [_retainRooms addObject:_centerRoomView.room4];
        [_retainRooms addObject:_centerRoomView.room3];
        [_retainRooms addObject:_centerRoomView];
    } else if (fromDoor==4) {
        xMove = -(_Length*sqrt(3)/2*2);
        [_needRemoveRooms addObject:_centerRoomView.room0];
        [_needRemoveRooms addObject:_centerRoomView.room1];
        [_needRemoveRooms addObject:_centerRoomView.room2];
        nextCenterRoomView = _centerRoomView.room4;
        nextCenterRoomView.room0 = _centerRoomView.room3;
        if (nextCenterRoomView.room0) { nextCenterRoomView.room0.FromDoor = 0; }
        nextCenterRoomView.room1 = _centerRoomView;
        if (nextCenterRoomView.room1) { nextCenterRoomView.room1.FromDoor = 1; }
        nextCenterRoomView.room2 = _centerRoomView.room5;
        if (nextCenterRoomView.room2) { nextCenterRoomView.room2.FromDoor = 2; }
        [_retainRooms addObject:_centerRoomView.room3];
        [_retainRooms addObject:_centerRoomView.room4];
        [_retainRooms addObject:_centerRoomView.room5];
        [_retainRooms addObject:_centerRoomView];
    } else if (fromDoor==5) {
        xMove = - _Length*sqrt(3)/2;
        yMove = _Length + _Length/2;
        [_needRemoveRooms addObject:_centerRoomView.room0];
        [_needRemoveRooms addObject:_centerRoomView.room1];
        [_needRemoveRooms addObject:_centerRoomView.room3];
        nextCenterRoomView = _centerRoomView.room5;
        nextCenterRoomView.room1 = _centerRoomView.room2;
        if (nextCenterRoomView.room1) { nextCenterRoomView.room1.FromDoor = 1; }
        nextCenterRoomView.room3 = _centerRoomView.room4;
        if (nextCenterRoomView.room3) { nextCenterRoomView.room3.FromDoor = 3; }
        nextCenterRoomView.room0 = _centerRoomView;
        if (nextCenterRoomView.room0) { nextCenterRoomView.room0.FromDoor = 0; }
        [_retainRooms addObject:_centerRoomView.room2];
        [_retainRooms addObject:_centerRoomView.room4];
        [_retainRooms addObject:_centerRoomView.room5];
        [_retainRooms addObject:_centerRoomView];
    }
    //依次画中间房间、0-5号房间
    AIHexagonView *roomView;
    int xMoveCenter = _xCenter+xMove;
    int yMoveCenter = _yCenter+yMove;
    int x = 0;
    int y = 0;
    //6 Center room
    if (-9==fromDoor) {
        nextCenterRoomView = [self drawRoom:CGPointMake(xMoveCenter, yMoveCenter) edgeLength:_Length roomNumber:_currentRoomNo fromDoor:fromDoor];
        [nextCenterRoomView setBackgroundColor:COLOR_CURRENTROOM];
        [_newRooms addObject:nextCenterRoomView];
    }
    //0
    if (-9==fromDoor || 3==fromDoor || 0==fromDoor || 1==fromDoor) {
        x = xMoveCenter + _Length*sqrt(3)/2;
        y = yMoveCenter - _Length - _Length/2;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[0] intValue] fromDoor:0];
        nextCenterRoomView.room0 = roomView;
        [_newRooms addObject:roomView];
    }
    //1
    if (-9==fromDoor || 0==fromDoor || 1==fromDoor || 2==fromDoor) {
        x = xMoveCenter + _Length*sqrt(3)/2*2;
        y = yMoveCenter;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[1] intValue] fromDoor:1];
        nextCenterRoomView.room1 = roomView;
        [_newRooms addObject:roomView];
    }
    //2
    if (-9==fromDoor || 1==fromDoor || 2==fromDoor || 5==fromDoor) {
        x = xMoveCenter + _Length*sqrt(3)/2;
        y = yMoveCenter + _Length + _Length/2;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[2] intValue] fromDoor:2];
        nextCenterRoomView.room2 = roomView;
        [_newRooms addObject:roomView];
    }
    //3
    if (-9==fromDoor || 4==fromDoor || 3==fromDoor || 0==fromDoor) {
        x = xMoveCenter - _Length*sqrt(3)/2;
        y = yMoveCenter - _Length - _Length/2;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[3] intValue] fromDoor:3];
        nextCenterRoomView.room3 = roomView;
        [_newRooms addObject:roomView];
    }
    //4
    if (-9==fromDoor || 5==fromDoor || 4==fromDoor || 3==fromDoor) {
        x = xMoveCenter - (_Length*sqrt(3)/2*2);
        y = yMoveCenter;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[4] intValue] fromDoor:4];
        nextCenterRoomView.room4 = roomView;
        [_newRooms addObject:roomView];
    }
    //5
    if (-9==fromDoor || 2==fromDoor || 5==fromDoor || 4==fromDoor) {
        x = xMoveCenter - _Length*sqrt(3)/2;
        y = yMoveCenter + _Length + _Length/2;
        roomView = [self drawRoom:CGPointMake(x, y) edgeLength:_Length roomNumber:[_currentRoom[5] intValue] fromDoor:5];
        nextCenterRoomView.room5 = roomView;
        [_newRooms addObject:roomView];
    }
    //动画移动移除房间
    if (_centerRoomView) { //不是第1次，需要移动所有房间
        [UIView animateWithDuration:kMoveRoomsDuration
                         animations:^{
                             for (int i=0; i<_needRemoveRooms.count; i++) { //移动要移除的房间
                                 if (_needRemoveRooms[i]) {
                                     UIView *view = (UIView*)_needRemoveRooms[i];
                                     CGRect finalFrame = view.frame;
                                     finalFrame.origin.x = finalFrame.origin.x-xMove;
                                     finalFrame.origin.y = finalFrame.origin.y-yMove;
                                     view.frame = finalFrame;
                                     view.alpha = 0.0;
                                 }
                             }
                             for (int i=0; i<_retainRooms.count; i++) { //移动保留的房间
                                 if (_retainRooms[i]) {
                                     UIView *view = (UIView*)_retainRooms[i];
                                     CGRect finalFrame = view.frame;
                                     finalFrame.origin.x = finalFrame.origin.x-xMove;
                                     finalFrame.origin.y = finalFrame.origin.y-yMove;
                                     view.frame = finalFrame;
                                 }
                             }
                             for (int i=0; i<_newRooms.count; i++) { //移动新添加的房间
                                 UIView *view = (UIView*)_newRooms[i];
                                 CGRect finalFrame = view.frame;
                                 finalFrame.origin.x = finalFrame.origin.x-xMove;
                                 finalFrame.origin.y = finalFrame.origin.y-yMove;
                                 view.frame = finalFrame;
                                 view.alpha = 1.0;
                             }
                         }
                         completion:^(BOOL finished) {
                             while (_needRemoveRooms.count>0) { //删掉移除不显示的房间
                                 if (_needRemoveRooms[0]) {
                                     UIView *view = (UIView*)_needRemoveRooms[0];
                                     [_needRemoveRooms removeObjectAtIndex:0];
                                     [view removeFromSuperview];
                                 }
                             }
                         }];
    } else {
        [UIView animateWithDuration:kMoveRoomsDuration
                         animations:^{
                             for (int i=0; i<_newRooms.count; i++) {
                                 UIView *view = (UIView*)_newRooms[i];
                                 view.alpha = 1.0;
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
    }
    _centerRoomView = nextCenterRoomView;
    _centerRoomView.room0.RoomNumber = [_currentRoom[0] intValue];
    _centerRoomView.room1.RoomNumber = [_currentRoom[1] intValue];
    _centerRoomView.room2.RoomNumber = [_currentRoom[2] intValue];
    _centerRoomView.room3.RoomNumber = [_currentRoom[3] intValue];
    _centerRoomView.room4.RoomNumber = [_currentRoom[4] intValue];
    _centerRoomView.room5.RoomNumber = [_currentRoom[5] intValue];
    //打开beyes的时候进行处理
    [self updateBeeEyesRooms];
    //动画显示房间的颜色（可通、不可通）
    [_newRooms addObjectsFromArray:_retainRooms];
    [UIView animateWithDuration:kMoveRoomsDuration
                     animations:^{
                         for (int i=0; i<_newRooms.count; i++) {
                             AIHexagonView *roomView = (AIHexagonView*)_newRooms[i];
                             if (abs(_currentRoomNo)==INT_ENTRYROOM && abs(roomView.RoomNumber)==abs(_currentRoomNo)) {
                                 [roomView setTitle:NSLocalizedString(@"Let's go",nil)];
                             } else if (abs(_currentRoomNo)==_maze.RoomCount+1 && abs(roomView.RoomNumber)==abs(_currentRoomNo)) {
                                 [roomView setTitle:NSLocalizedString(@"Outside",nil)];
                             }
                             if (roomView.RoomNumber<0) {
                                 //通的房间
                                 [roomView layer].lineDashPattern = nil;
                                 [roomView setBackgroundColor:COLOR_CANINTOROOM];
                             } else if (roomView.RoomNumber>0) {
                                 //不通房间
                                 [roomView layer].lineDashPattern = nil;
                                 [roomView setBackgroundColor:COLOR_CANNOTINROOM];
                             } else if (roomView.RoomNumber==0) {
                                 //无效房间
                                 if ( (abs(_currentRoomNo)==INT_ENTRYROOM) || (abs(_currentRoomNo)==_maze.RoomCount+1)) {
                                     [roomView layer].lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:4], [NSNumber numberWithInt:4], nil];
                                     [roomView setBackgroundColor:COLOR_INVALIDROOM];
                                 } else {
                                     [roomView layer].lineDashPattern = nil;
                                     [roomView setBackgroundColor:COLOR_CANNOTINROOM];
                                 }
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(AIHexagonView*)drawRoom:(CGPoint)centerPostion edgeLength:(int)length roomNumber:(int)roomNumber fromDoor:(int)fromDoor {
    int x = centerPostion.x;
    int y = centerPostion.y-length;
    NSArray *points = [[NSArray alloc] initWithObjects:
                          [NSValue valueWithCGPoint:CGPointMake(x, y)],
                          [NSValue valueWithCGPoint:CGPointMake(x+length*sqrt(3)/2,y+length*1/2)],
                          [NSValue valueWithCGPoint:CGPointMake(x+length*sqrt(3)/2,y+length*1/2+length)],
                          [NSValue valueWithCGPoint:CGPointMake(x,y+length+length)],
                          [NSValue valueWithCGPoint:CGPointMake(x-length*sqrt(3)/2,y+length*1/2+length)],
                          [NSValue valueWithCGPoint:CGPointMake(x-length*sqrt(3)/2,y+length*1/2)],
                          nil];
    AIHexagonView *roomView = [[AIHexagonView alloc] initWithPoints:points];
    roomView.RoomNumber = roomNumber;
    roomView.FromDoor = fromDoor;
    roomView.EdgeLength = length;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRoom:)];
    [roomView addGestureRecognizer:tapGesture];
    roomView.alpha = 0.0;
    [self.view addSubview:roomView];
    [self.view sendSubviewToBack:roomView];
    return roomView;
}

-(void)clickRoom:(AIHexagonView*)view {
    if (view.RoomNumber<0 && view.RoomNumber!=_currentRoomNo) {
        [_steps addObject:[NSNumber numberWithInt:view.FromDoor]];
        [self drawRooms:view.RoomNumber fromDoor:view.FromDoor];
        [self updateStarStatus:abs(view.RoomNumber)];
        //走出迷宫做本局结束处理
        if (abs(view.RoomNumber)==_maze.RoomCount+1) {
            //走到出口
            _btnNewGame.hidden = NO;
            _btnShare.hidden = NO;
            if (_gotStars.count<_starRooms.count) {
                _labelMessage.hidden = NO;
            } else {
                _labelMessage.hidden = YES;
                [self endAndSaveCurrentGame];
            }
        } else {
            //游戏中房间，保存当前房间位置
            if (self.IsChallenge) {
                [[NSUserDefaults standardUserDefaults] setObject:_steps forKey:@"ChallengeSteps"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:view.RoomNumber] forKey:@"ChallengeRoomNo"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[_timerLabel getTimeCounted]] forKey:@"ChallengeSpentTime"];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:_steps forKey:@"GameSteps"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:view.RoomNumber] forKey:@"GameRoomNo"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[_timerLabel getTimeCounted]] forKey:@"GameSpentTime"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self updateSteps];
    }
}
-(void)tapRoom:(UITapGestureRecognizer *)recognizer {
    if (!_timerLabel.counting) return;
    AIHexagonView *view = (AIHexagonView*)recognizer.view;
    [self clickRoom:view];
}

-(void)updateBeeEyesRoom:(AIHexagonView *)roomView
{
    //根据指定房间更新当前游戏beyes数组，决定房间是否显示编号
    int roomno = abs(roomView.RoomNumber);
    if (_openBeeEyes && _beyedynamic>0 && roomno>0 && roomno!=INT_ENTRYROOM && roomno!=_maze.RoomCount+1 && ![_beyesRooms containsObject:[NSNumber numberWithInt:roomno]]) {
        [_beyesRooms addObject:[NSNumber numberWithInt:roomno]];
        _beyedynamic = _beyedynamic - 1;
        _consumeBeyes = _consumeBeyes + 1;
    }
    roomView.showRoomNumber = [_beyesRooms containsObject:[NSNumber numberWithInt:roomno]] || (_openBeeEyes && _beyedynamic>0 && (roomno==INT_ENTRYROOM || roomno==_maze.RoomCount+1));
}

- (void)updateBeeEyesRooms
{
    //更新当前游戏beyes数组
    int count1 = _beyesRooms.count;
    [self updateBeeEyesRoom:_centerRoomView];
    [self updateBeeEyesRoom:_centerRoomView.room0];
    [self updateBeeEyesRoom:_centerRoomView.room1];
    [self updateBeeEyesRoom:_centerRoomView.room2];
    [self updateBeeEyesRoom:_centerRoomView.room3];
    [self updateBeeEyesRoom:_centerRoomView.room4];
    [self updateBeeEyesRoom:_centerRoomView.room5];
    int count2 = _beyesRooms.count;
    if (count1 != count2) {
        if (_IsChallenge) {
            [[NSUserDefaults standardUserDefaults] setObject:[_beyesRooms allObjects] forKey:@"ChallengeBeeEyesRooms"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[_beyesRooms allObjects] forKey:@"GameBeeEyesRooms"];
        }
        [self showBeeEyesNumber];
    }
}

- (void)endAndSaveCurrentGame
{
    [self saveAndClearPlayingData];
}

- (void)updateSteps
{
    _labelSteps.text = [NSString stringWithFormat:@"%d",_steps.count];
}

- (void)updateStarStatus:(int)newRoom
{
    if (newRoom>0 && ![_gotStars containsObject:[NSString stringWithFormat:@"%d",newRoom]] && [_starRooms containsObject:[NSString stringWithFormat:@"%d",newRoom]]) {
        int xmove = _gotStars.count*18;
        if (_gotStars.count<_starRooms.count) {
            [_gotStars addObject:[NSString stringWithFormat:@"%d",newRoom]];
        }
        if (self.IsChallenge) {
            [[NSUserDefaults standardUserDefaults] setObject:_gotStars forKey:@"ChallengeGotStars"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:_gotStars forKey:@"GameGotStars"];
        }
        //
        UILabel* labelStar = [[UILabel alloc] initWithFrame:CGRectMake(_xCenter-20,_yCenter-20,40,40)];
        labelStar.textAlignment = NSTextAlignmentLeft;
        [labelStar setTextColor:[UIColor orangeColor]];
        UIFont * fontTwo = [UIFont fontWithName:@"FontAwesome" size:20];
        [labelStar setFont:fontTwo];
        NSString *iconString = [NSString stringFromAwesomeIcon:FAIconStar];
        [labelStar setText:[NSString stringWithFormat:@"%@",iconString]];
        [self.view addSubview:labelStar];
        [UIView animateWithDuration:0.8
                         animations:^{
                             labelStar.frame = CGRectMake(_labelStars.frame.origin.x+xmove,_labelStars.frame.origin.y,_labelStars.frame.size.width,_labelStars.frame.size.height);;
                         }
                         completion:^(BOOL finished) {
                             NSString *title = @"";
                             NSString *iconStarEmpty = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
                             NSString *iconStarGot = [NSString stringFromAwesomeIcon:FAIconStar];
                             for (int i=0; i<_gotStars.count; i++) {
                                 title = [NSString stringWithFormat:@"%@%@", title,iconStarGot];
                             }
                             int cnt = _starRooms.count-_gotStars.count;
                             for (int i=1; i<=cnt; i++) {
                                 title = [NSString stringWithFormat:@"%@%@", title,iconStarEmpty];
                             }
                             _labelStars.text = title;
                             [labelStar removeFromSuperview];
                         }];
    } else if (newRoom==-9) {
        NSString *title = @"";
        NSString *iconStarEmpty = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
        NSString *iconStarGot = [NSString stringFromAwesomeIcon:FAIconStar];
        for (int i=0; i<_gotStars.count; i++) {
            title = [NSString stringWithFormat:@"%@%@", title,iconStarGot];
        }
        int cnt = _starRooms.count-_gotStars.count;
        for (int i=0; i<(cnt); i++) {
            title = [NSString stringWithFormat:@"%@%@", title,iconStarEmpty];
        }
        _labelStars.text = title;
    }
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

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertview clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertview.title isEqualToString:NSLocalizedString(@"Tip",nil)] && buttonIndex==1) {
        //RenewGame
        _beyeRetain = [_database getBeeEyeRetain];
        _beyedynamic = _beyeRetain;
        _consumeBeyes = 0;
        [_beyesRooms removeAllObjects];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameBeeEyesRooms"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CacheMaze"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSpentTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameRoomNo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameGotStars"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSteps"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self initGame];
    }
}

#pragma mark - WSCoachMarksViewDelegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index
{
    if (index==3 || index==19) {
        [self clickRoom:_centerRoomView.room2];
    } else if (index==12) {
        [self clickRoom:_centerRoomView.room1];
    } else if (index==13 || index==21) {
        [self clickRoom:_centerRoomView.room0];
    } else if (index==18) {
        [self clickRoom:_centerRoomView.room5];
    } else if (index==20) {
        [self clickRoom:_centerRoomView.room3];
    } else if (index==4) {
        if (!_openBeeEyes) {
            [self clickSwitchBeye];
        }
    }
}
- (void)coachMarksViewDidCleanup:(WSCoachMarksView *)coachMarksView
{
    NSLog(@"Guid done.");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShownWalkingView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self clickBackButton];
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
    [self timeSuspend];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidDismissScreen");
    [self timeResume];
}

@end
