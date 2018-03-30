//
//  WalkingViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Consts.h"
#import "HoneyComb.h"
#import "AIHexagonView.h"
#import "WSCoachMarksView.h"
#import "MZTimerLabel.h"
#import "SqliteDatabase.h"

@interface WalkingViewController : UIViewController <WSCoachMarksViewDelegate, ADBannerViewDelegate, GADBannerViewDelegate> {
    int _Length;
    int _xCenter;
    int _yCenter;
    int _beyedynamic;
    int _beyeRetain;
    int _consumeBeyes;
    BOOL _isGuide;
    NSMutableDictionary *_jsonStages;
    
    ADBannerView *_iadBannerView;
    GADBannerView *_admobBannerView;
    
    UILabel *_labelLevel;
    UILabel *_labelStars;
    MZTimerLabel *_timerLabel;
    UILabel *_labelSteps;
    UIButton *_btnMenu;
    UIButton *_btnRenewGame;
    UIButton *_btnViewMaze;
    UIButton *_btnSwitchBeye;
    UILabel *_labelBeyeNumber;
    BOOL _openBeeEyes;
    
    UILabel *_labelMessage;
    UIButton *_btnNewGame;
    UIButton *_btnShare;

    SqliteDatabase *_database;
    HoneyComb *_maze;

    int _currentRoomNo;
    NSMutableArray *_currentRoom;
    AIHexagonView *_centerRoomView;
    NSMutableArray *_starRooms;
    NSMutableArray *_gotStars;
    NSMutableArray *_steps;
    NSMutableSet *_beyesRooms;
}

@property (nonatomic, copy) NSString *ChallengeId;
@property (nonatomic, copy) NSString *ChallengeName;
@property (nonatomic, copy) NSString *MazeData;
@property (assign, nonatomic) BOOL IsChallenge;

-(void)tapRoom:(UITapGestureRecognizer *)recognizer;

@end
