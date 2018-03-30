//
//  WalkingViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Consts.h"

#define COLOR_BACKGROUND   [UIColor colorWithRed:249/255.0 green:247/255.0 blue:235/255.0 alpha:1] //249/247/235
#define COLOR_CANNOTINROOM [UIColor colorWithRed:238/255.0 green:225/255.0 blue:199/255.0 alpha:1] //232/218/189
#define COLOR_CANINTOROOM  [UIColor colorWithRed:239/255.0 green:199/255.0 blue:31/255.0 alpha:1]  //230/186/37
#define COLOR_INVALIDROOM  [UIColor clearColor]
#define COLOR_CURRENTROOM  [UIColor whiteColor]

extern void CGPathPrint(CGPathRef path, FILE* file);

@interface AIHexagonView : UIView{
    UILabel *_labelTitle;

}

@property (assign, nonatomic) int RoomNumber;
@property (assign, nonatomic) int FromDoor;
@property (assign, nonatomic) int EdgeLength;
@property (assign, nonatomic) BOOL IsStarRoom;
@property (assign, nonatomic) BOOL showRoomNumber;
@property (strong, nonatomic) AIHexagonView *room0;
@property (strong, nonatomic) AIHexagonView *room1;
@property (strong, nonatomic) AIHexagonView *room2;
@property (strong, nonatomic) AIHexagonView *room3;
@property (strong, nonatomic) AIHexagonView *room4;
@property (strong, nonatomic) AIHexagonView *room5;

-(CAShapeLayer*)layer;

-(id)initWithPoints:(NSArray*)points;
-(void)setTitle:(NSString*)title;
-(void)setCurrentRoom;

@end
