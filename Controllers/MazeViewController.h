//
//  MazeViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/12.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoneyComb.h"
#import "AIHexagonView.h"

@interface MazeViewController : UIViewController {
    NSMutableArray *_roomCenterPos;
    NSMutableArray *_pathRoomPos;
    NSMutableArray *_pathTrapsPos;
    CFTimeInterval _timeDrawLineDuration;
    int _lindex;
    int _roomTotalCount;
    CGRect _mazeRect;
    UILabel *_labelStars;
    UILabel *_timerLabel;
    UIButton *_btnShare;
}

@property (nonatomic, copy) NSString *MazeData;
@property (nonatomic, assign) int StarTotal;
@property (nonatomic, assign) int StarGot;
@property (nonatomic, copy) NSString *timeText;
@property (nonatomic, copy) NSString *Steps;
@property (assign, nonatomic) BOOL showRoomNumber;
@property (assign, nonatomic) BOOL showShareButton;
@property (nonatomic, copy) NSString *StageTitle;
@property (nonatomic, assign) int currentRoomNumber;

-(void)calcPoints;
-(UIImage*)getSnapshot:(NSString*)spentTime;

@end
