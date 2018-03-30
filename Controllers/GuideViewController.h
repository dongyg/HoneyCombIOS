//
//  GuideViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//
//  教程不再使用这个视图

#import <UIKit/UIKit.h>
#import "HoneyComb.h"
#import "CEGuideArrow.h"

@interface GuideViewController : UIViewController <CEGuideArrowDelegate> {
    HoneyComb *_maze;
    int _currentRoomNo;
    NSMutableArray *_currentRoom;
    NSMutableArray *_showRooms;
    
    UIButton *_btnMenu;
}

@end
