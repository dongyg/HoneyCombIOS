//
//  GuideViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//
//  教程不再使用这个视图

#import "GuideViewController.h"
#import "AIHexagonView.h"
#import "AppDelegate.h"
#import "UIButton+Bootstrap.h"

#define APP_WINDOW  (((AppDelegate *)[[UIApplication sharedApplication] delegate]).window)

@interface GuideViewController ()

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:COLOR_BACKGROUND];

    _btnMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnMenu setFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height-110, 200, 60)];
    [_btnMenu addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [_btnMenu setTitle:NSLocalizedString(@"Start to game",nil) forState:UIControlStateNormal];
    [_btnMenu.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [_btnMenu infoStyle];
    _btnMenu.hidden = YES;
    [self.view addSubview:_btnMenu];

    [[CEGuideArrow sharedGuideArrow] setDelegate:self];

    _showRooms = [[NSMutableArray alloc] init];
    _maze = [[HoneyComb alloc] initWithJsonData:@"{\"Level\":2,\"StartRoom\":1,\"EntryDoor\":0,\"Path\":\"254\"}"];
    _currentRoomNo = -INT_ENTRYROOM;
    [self drawRooms:_currentRoomNo fromDoor:-9];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[CEGuideArrow sharedGuideArrow] removeAnimated:FALSE];
}

-(void)drawRooms:(int)centerRoom fromDoor:(int)fromDoor {
    //-INT_ENTRYROOM代表入口前的虚拟房间；RoomCount-1代表出口的虚拟房间；其它代表普通房间（负的为可通，正的为不通）
    if ( centerRoom==0 || (abs(centerRoom)!=INT_ENTRYROOM && abs(centerRoom)>_maze.RoomCount+1) ) {
        NSLog(@"Invalid Room: %d",centerRoom);
        return;
    }
    //保存当前中心房间编号，和房间对象
    _currentRoomNo = centerRoom;
    if (abs(centerRoom)==INT_ENTRYROOM) {
        _currentRoom = [_maze Room:0];
    } else {
        _currentRoom = [_maze Room:abs(centerRoom)];
    }
    int length = MIN(self.view.frame.size.width, self.view.frame.size.height);
    length = length*0.8/3/sqrt(3); //50;
    int xCenter = self.view.frame.size.width/2;
    int yCenter = self.view.frame.size.height/2;
    int xMove = 0;
    int yMove = 0;
    //根据从哪个房间走进来决定画房间的偏移量；初始时无偏移量直接画在中间
    if (fromDoor==0) {
        xMove = length*sqrt(3)/2;
        yMove = - length - length/2;
    } else if (fromDoor==1) {
        xMove = length+sqrt(3);
    } else if (fromDoor==2) {
        xMove = length*sqrt(3)/2;
        yMove = length + length/2;
    } else if (fromDoor==3) {
        xMove = - length*sqrt(3)/2;
        yMove = - length - length/2;
    } else if (fromDoor==4) {
        xMove = -(length+sqrt(3));
    } else if (fromDoor==5) {
        xMove = - length*sqrt(3)/2;
        yMove = length + length/2;
    }
    //依次画中间房间；0-5号房间
    //Center room
    int xMoveCenter = xCenter+xMove;
    int yMoveCenter = yCenter+yMove;
    [self drawRoom:CGPointMake(xMoveCenter, yMoveCenter) edgeLength:length roomNumber:_currentRoomNo fromDoor:fromDoor];
    //[roomView setBackgroundColor:COLOR_CURRENTROOM];
    //0
    int x = xMoveCenter + length*sqrt(3)/2;
    int y = yMoveCenter - length - length/2;
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[0] intValue] fromDoor:0];
    //1
    x = xMoveCenter + length*sqrt(3);
    y = yMoveCenter;
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[1] intValue] fromDoor:1];
    //2
    x = xMoveCenter + length*sqrt(3)/2;
    y = yMoveCenter + length + length/2;
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[2] intValue] fromDoor:2];
    //3
    x = xMoveCenter - length*sqrt(3)/2;
    y = yMoveCenter - length - length/2;
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[3] intValue] fromDoor:3];
    //4
    x = xMoveCenter - length*sqrt(3);
    y = yMoveCenter;
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[4] intValue] fromDoor:4];
    //5
    x = xMoveCenter - length*sqrt(3)/2;
    y = yMoveCenter + length + length/2;
    
    [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:[_currentRoom[5] intValue] fromDoor:5];
    //动画显示房间，和移动移除房间
    if (_showRooms.count==7) {
        [UIView animateWithDuration:2
                         animations:^{
                             for (int i=0; i<7; i++) {
                                 UIView *view = (UIView*)_showRooms[i];
                                 view.alpha = 1.0;
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
    } else if (_showRooms.count==14) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (int i=0; i<14; i++) {
                                 UIView *view = (UIView*)_showRooms[i];
                                 if (xMove!=0 || yMove!=0) {
                                     CGRect finalFrame = view.frame;
                                     finalFrame.origin.x = finalFrame.origin.x-xMove;
                                     finalFrame.origin.y = finalFrame.origin.y-yMove;
                                     view.frame = finalFrame;
                                 }
                                 if (i<7) {
                                     view.alpha = 0.0;
                                 } else {
                                     view.alpha = 1.0;
                                 }
                             }
                         }
                         completion:^(BOOL finished) {
                             for (int i=0; i<7; i++) {
                                 [(UIView*)_showRooms[0] removeFromSuperview];
                                 [_showRooms removeObjectAtIndex:0];
                             }
                         }];
    }
    //画指示箭头
    //route:5254
    //NSLog(@"Draw: %d, %d",centerRoom,fromDoor);
    CGPoint pos = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    if (abs(centerRoom)==INT_ENTRYROOM) {
        pos = CGPointMake(pos.x - length*sqrt(3)/2,pos.y + length + length/2);
    } else if (abs(centerRoom)==1) {
        pos = CGPointMake(pos.x + length*sqrt(3)/2,pos.y + length + length/2);
    } else if (abs(centerRoom)==4) {
        pos = CGPointMake(pos.x - length*sqrt(3)/2,pos.y + length + length/2);
    } else if (abs(centerRoom)==6) {
        pos = CGPointMake(pos.x - length*sqrt(3),pos.y);
    } else {
        [[CEGuideArrow sharedGuideArrow] removeAnimated:FALSE];
        return;
    }
    [[CEGuideArrow sharedGuideArrow] showInWindow:APP_WINDOW atPoint:pos inView:self.view atAngle:45.0 length:100.0];
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
    [_showRooms addObject:roomView];
    roomView.RoomNumber = roomNumber;
    roomView.FromDoor = fromDoor;
    roomView.EdgeLength = length;
    if (abs(_currentRoomNo)==INT_ENTRYROOM && abs(roomNumber)==abs(_currentRoomNo)) {
        [roomView setTitle:NSLocalizedString(@"Let's go",nil)];
    } else if (abs(_currentRoomNo)==_maze.RoomCount+1 && abs(roomNumber)==abs(_currentRoomNo)) {
        [roomView setTitle:NSLocalizedString(@"Outside",nil)];
    }
    if (roomNumber<0) {
        //通的房间
        [roomView layer].lineDashPattern = nil;
        [roomView setBackgroundColor:COLOR_CANINTOROOM];
    } else if (roomNumber>0) {
        //不通房间
        [roomView layer].lineDashPattern = nil;
        [roomView setBackgroundColor:COLOR_CANNOTINROOM];
    } else if (roomNumber==0) {
        //不通房间
        if ( (abs(_currentRoomNo)==INT_ENTRYROOM) || (abs(_currentRoomNo)==_maze.RoomCount+1)) {
            [roomView layer].lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:4], [NSNumber numberWithInt:4], nil];
            [roomView setBackgroundColor:COLOR_INVALIDROOM];
        } else {
            [roomView layer].lineDashPattern = nil;
            [roomView setBackgroundColor:COLOR_CANNOTINROOM];
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRoom:)];
    [roomView addGestureRecognizer:tapGesture];
    roomView.alpha = 1.0;
    [self.view addSubview:roomView];
    return roomView;
}

-(void)tapRoom:(UITapGestureRecognizer *)recognizer {
    AIHexagonView *view = (AIHexagonView*)recognizer.view;
    //NSLog(@"Tap room : %i",view.RoomNumber);
    if (view.RoomNumber<0 && view.RoomNumber!=_currentRoomNo) {
        [self drawRooms:view.RoomNumber fromDoor:view.FromDoor];
        if (abs(view.RoomNumber)==_maze.RoomCount+1) {
            _btnMenu.hidden = NO;
        }
    }
}

#pragma mark - CEGuideArrowDelegate methods

- (BOOL)ceGuideArrow:(CEGuideArrow *)guideArrow shouldShowArrowInWindow:(UIWindow *)window atPoint:(CGPoint)point inView:(UIView *)view length:(CGFloat)length
{
    return YES;
}

- (void)ceGuideArrow:(CEGuideArrow *)guideArrow willAppearInWindow:(UIWindow *)window atPoint:(CGPoint)point inView:(UIView *)view length:(CGFloat)length
{
//    NSLog(@"Guide Arrow willAppear:");
}

- (void)ceGuideArrow:(CEGuideArrow *)guideArrow didAppearInWindow:(UIWindow *)window atPoint:(CGPoint)point inView:(UIView *)view length:(CGFloat)length
{
//    NSLog(@"Guide Arrow didAppear:");
}

- (void)ceGuideArrow:(CEGuideArrow *)guideArrow willDisappearInWindow:(UIWindow *)window atPoint:(CGPoint)point inView:(UIView *)view length:(CGFloat)length
{
//    NSLog(@"Guide Arrow willDisappear:");
}

- (void)ceGuideArrow:(CEGuideArrow *)guideArrow didDisappearInWindow:(UIWindow *)window atPoint:(CGPoint)point inView:(UIView *)view length:(CGFloat)length
{
//    NSLog(@"Guide Arrow didDisapear:");
}

@end
