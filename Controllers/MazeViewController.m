//
//  MazeViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/12.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "MazeViewController.h"
#import "SqliteDatabase.h"
#import "ShapeView.h"
#import "UIButton+Bootstrap.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "QQSessionActivity.h"
#import "QQZoneActivity.h"

static CFTimeInterval const kDuration = 2.0;
static CGFloat const kPointDiameter = 0.0;

@interface MazeViewController ()

@end

@implementation MazeViewController
@synthesize MazeData = _MazeData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *_btnBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnBack setFrame:CGRectMake(20, 30, 40, 40)];
    [_btnBack addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [_btnBack setTitle:@"" forState:UIControlStateNormal];
    [_btnBack warningStyle];
    [_btnBack addAwesomeIcon:FAIconArrowLeft beforeTitle:NO];
    [self.view addSubview:_btnBack];
    //
    CGSize snapSize = self.view.bounds.size;
    CGFloat y = (snapSize.height-snapSize.width)/2;
    //
    _labelStars = [[UILabel alloc] initWithFrame:CGRectMake(20,y-10,100,30)];
    _labelStars.textAlignment = NSTextAlignmentLeft;
    _labelStars.font = [UIFont systemFontOfSize:20];
    UIFont * fontTwo = [UIFont fontWithName:@"FontAwesome" size:20];
    [_labelStars setTextColor:[UIColor orangeColor]];
    [_labelStars setFont:fontTwo];
    NSString *iconString = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
    [_labelStars setText:[NSString stringWithFormat:@"%@%@%@%@",iconString,iconString,iconString,iconString]];
    [self.view addSubview:_labelStars];
    NSString *title = @"";
    NSString *iconStarEmpty = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
    NSString *iconStarGot = [NSString stringFromAwesomeIcon:FAIconStar];
    for (int i=0; i<self.StarGot; i++) {
        title = [NSString stringWithFormat:@"%@%@", title,iconStarGot];
    }
    int cnt = self.StarTotal-self.StarGot;
    for (int i=1; i<=cnt; i++) {
        title = [NSString stringWithFormat:@"%@%@", title,iconStarEmpty];
    }
    _labelStars.text = title;
    //
    _timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-60, y-10, 120, 30)];
    [self.view addSubview:_timerLabel];
    _timerLabel.backgroundColor = [UIColor clearColor];
    _timerLabel.textColor = [UIColor brownColor];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    _timerLabel.text = _timeText;
    //
    _btnShare = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnShare setFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height-70, 200, 40)];
    [_btnShare addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
    [_btnShare infoStyle];
    [_btnShare setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [_btnShare addAwesomeIcon:FAIconShare beforeTitle:YES];
    _btnShare.hidden = !_showShareButton;
    [self.view addSubview:_btnShare];

    [self calcPoints];
    [self.view setBackgroundColor:COLOR_BACKGROUND];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self drawMaze];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //不支持除竖屏以外的方向，所以这个方法其实已经没有用了
    [_btnShare setFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height-70, 200, 40)];
}

-(void)clickBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickShare
{
    UIImage *imageToShare = [self capatureMazeImage];

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
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_AWARD,nil),self.StageTitle] forKey:@"ShareSummary"];
                [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"ShareNumber"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                //其他iOS系统内的完成后即为分享成功
                int setnum = [[SqliteDatabase database] UpdateBeeEyeNumber:10 summary:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(STRING_BEYE_AWARD,nil),self.StageTitle]];
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

-(UIImage*)getSnapshot:(NSString*)spentTime
{
    //添加path的UIView
    ShapeView  *pathShapeView = [[ShapeView alloc] init];
    pathShapeView.backgroundColor = [UIColor clearColor];
    pathShapeView.opaque = NO;
    pathShapeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pathShapeView];
    //设置线条的颜色
    UIColor *pathColor = [UIColor blueColor];
    pathShapeView.shapeLayer.fillColor = nil;
    pathShapeView.shapeLayer.strokeColor = pathColor.CGColor;
    //合并路径点和陷阱点
    NSMutableArray *_pathAllPoints = [[NSMutableArray alloc] initWithArray:_pathTrapsPos];
    [_pathAllPoints addObject:_pathRoomPos];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    for (int i=0;i<_pathAllPoints.count;i++) {
        if ([_pathAllPoints[i] count] >= 2) {
            [path moveToPoint:[[_pathAllPoints[i] firstObject] CGPointValue]];
            for (int j = 1; j<[_pathAllPoints[i] count]; j++) {
                [path addLineToPoint:[_pathAllPoints[i][j] CGPointValue]];
            }
        }
    }
    path.usesEvenOddFillRule = YES;
    pathShapeView.shapeLayer.path = path.CGPath;
    _timerLabel.text = spentTime;
    return [self capatureMazeImage];
}

-(UIImage*)capatureMazeImage
{
    //从视图得到Image
    CGSize snapSize = self.view.bounds.size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat y = (snapSize.height-snapSize.width)/2;
    CGRect myImageRect = CGRectMake(0, (y-10)*scale, snapSize.width*scale, (snapSize.width+20)*scale);
    // UIGraphicsBeginImageContext(snapSize); //这个大概是按iPhone4前的屏幕尺寸
    UIGraphicsBeginImageContextWithOptions(snapSize, self.view.opaque, 0.0); //这个根据屏幕密度
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //裁剪
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, myImageRect);
    image = [UIImage imageWithCGImage:subImageRef];
    //NSLog(@"%f, %f, %f",image.size.width,image.size.height, [[UIScreen mainScreen] scale]);
    //NSLog(@"%f, %f, %f, %f",myImageRect.origin.x, myImageRect.origin.y,myImageRect.size.width,myImageRect.size.height);
    //把截图和QR图拼接成一个图
    UIImage *imageQRwww = [UIImage imageNamed:@"qr_www.png"];
    UIImage *imageScreen = [self reSizeImage:image toSize:CGSizeMake(480, 480)];
    CGSize size= CGSizeMake(imageQRwww.size.width+imageScreen.size.width, imageQRwww.size.height);
    UIGraphicsBeginImageContext(size);
    [imageQRwww drawInRect:CGRectMake(0, 0, imageQRwww.size.width, imageQRwww.size.height)];
    [imageScreen drawInRect:CGRectMake(imageQRwww.size.width, 0, imageScreen.size.width, imageScreen.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    //图像自定长宽缩放
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)calcPoints
{
    CGFloat posMinX = self.view.frame.size.width;
    CGFloat posMinY = self.view.frame.size.height;
    CGFloat posMaxX = 0;  CGFloat posMaxY = 0;
    //计算生成路径连线的点数组；并创建房间
    HoneyComb *_maze = [[HoneyComb alloc] initWithJsonData:self.MazeData];
    NSDictionary *mazeDict = [HoneyComb getObjectFromJson:self.MazeData];
    NSArray *starRooms = [mazeDict objectForKey:@"Stars"];
    //NSLog(@"%@",starRooms);
    CGFloat widthContainer = MIN(self.view.frame.size.width, self.view.frame.size.height) - 20;
    _roomCenterPos = [[NSMutableArray alloc] init];
    int maxCount = _maze.Level * 2 - 1;
    int length = widthContainer / maxCount / sqrt(3);
    int xCenter = self.view.frame.size.width/2;
    int yCenter = self.view.frame.size.height/2;
    int x = 0, y = 0, iLoop = 1;
    int xEntryPos = 0, yEntryPos = 0;
    _roomTotalCount = [_maze RoomCount];
    [_roomCenterPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
    //Level行
    for (int i = _maze.Level-1; i>=0; i--) {
        x = xCenter - length*sqrt(3)/2 * (maxCount-i-1);
        y = yCenter - length*3/2 * (i);
        posMinX = MIN(xCenter, posMinX);  posMaxX = MAX(xCenter, posMaxX);
        posMinY = MIN(yCenter, posMinY);  posMaxY = MAX(yCenter, posMaxY);
        for (int j = 0; j<maxCount-i; j++) {
            AIHexagonView *roomView = [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:iLoop];
            if ([starRooms containsObject:[NSString stringWithFormat:@"%d",iLoop]]) {
                roomView.IsStarRoom = YES;
            }
            [_roomCenterPos addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            iLoop++;
            x = x + length*sqrt(3);
        }
    }
    //Level-1行
    for (int i = 1; i<=_maze.Level-1; i++) {
        x = xCenter - length*sqrt(3)/2 * (maxCount-i-1);
        y = yCenter + length*3/2 * (i);
        posMinX = MIN(xCenter, posMinX);  posMaxX = MAX(xCenter, posMaxX);
        posMinY = MIN(yCenter, posMinY);  posMaxY = MAX(yCenter, posMaxY);
        for (int j = 0; j<maxCount-i; j++) {
            AIHexagonView *roomView = [self drawRoom:CGPointMake(x, y) edgeLength:length roomNumber:iLoop];
            if ([starRooms containsObject:[NSString stringWithFormat:@"%d",iLoop]]) {
                roomView.IsStarRoom = YES;
            }
            [_roomCenterPos addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            iLoop++;
            x = x + length*sqrt(3);
        }
    }
    //入口路径起点
    NSValue *valPos = [_roomCenterPos objectAtIndex:_maze.StartRoom];
    xEntryPos = [valPos CGPointValue].x;
    yEntryPos = [valPos CGPointValue].y;
    if (_maze.DoorEntry==0) {
        xEntryPos = xEntryPos + length*sqrt(3)/2;
        yEntryPos = yEntryPos - length*3/2;
    } else if (_maze.DoorEntry==1) {
        xEntryPos = xEntryPos + length*sqrt(3);
    } else if (_maze.DoorEntry==2) {
        xEntryPos = xEntryPos + length*sqrt(3)/2;
        yEntryPos = yEntryPos + length*3/2;
    } else if (_maze.DoorEntry==3) {
        xEntryPos = xEntryPos - length*sqrt(3)/2;
        yEntryPos = yEntryPos - length*3/2;
    } else if (_maze.DoorEntry==4) {
        xEntryPos = xEntryPos - length*sqrt(3);
    } else if (_maze.DoorEntry==5) {
        xEntryPos = xEntryPos - length*sqrt(3)/2;
        yEntryPos = yEntryPos + length*3/2;
    }
    [_roomCenterPos replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
    //画线路径
    _pathRoomPos = [[NSMutableArray alloc] init];
    [_pathRoomPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
    xEntryPos = [valPos CGPointValue].x; //StartRoom.x
    yEntryPos = [valPos CGPointValue].y; //StartRoom.y
    NSString *mainPath = [mazeDict objectForKey:@"Path"];
    int roomIndex = _maze.StartRoom; int nextRoom = 0; int doorIndex = 0;
    _timeDrawLineDuration = MIN([mainPath length]/10.0, kDuration);
    for(int i = 0; i < [mainPath length]; i++) {
        [_pathRoomPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
        doorIndex = [[mainPath substringWithRange:NSMakeRange(i, 1)] intValue];
        valPos = [_roomCenterPos objectAtIndex:roomIndex];
        xEntryPos = [valPos CGPointValue].x;
        yEntryPos = [valPos CGPointValue].y;
        nextRoom = [[[_maze Room:roomIndex] objectAtIndex:doorIndex] intValue];
        roomIndex = abs(nextRoom);
    }
    [_pathRoomPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
    //出口点
    if (doorIndex==0) {
        xEntryPos = xEntryPos + length*sqrt(3)/2;
        yEntryPos = yEntryPos - length*3/2;
    } else if (doorIndex==1) {
        xEntryPos = xEntryPos + length*sqrt(3);
    } else if (doorIndex==2) {
        xEntryPos = xEntryPos + length*sqrt(3)/2;
        yEntryPos = yEntryPos + length*3/2;
    } else if (doorIndex==3) {
        xEntryPos = xEntryPos - length*sqrt(3)/2;
        yEntryPos = yEntryPos - length*3/2;
    } else if (doorIndex==4) {
        xEntryPos = xEntryPos - length*sqrt(3);
    } else if (doorIndex==5) {
        xEntryPos = xEntryPos - length*sqrt(3)/2;
        yEntryPos = yEntryPos + length*3/2;
    }
    [_pathRoomPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
    //陷阱路线
    NSDictionary *traps = [mazeDict objectForKey:@"Traps"];
    _pathTrapsPos = [[NSMutableArray alloc] init];
    for (NSString *key in traps) {
        //NSLog(@"key: %@ value: %@", key, traps[key]);
        NSString *trapPath = traps[key];
        NSMutableArray *currTrapPos = [[NSMutableArray alloc] init];
        int roomIndex = [key intValue];
        int nextRoom = 0; int doorIndex = 0;
        NSValue *valPos = [_roomCenterPos objectAtIndex:roomIndex];
        xEntryPos = [valPos CGPointValue].x;
        yEntryPos = [valPos CGPointValue].y;
        for(int i = 0; i < [trapPath length]; i++) {
            [currTrapPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
            doorIndex = [[trapPath substringWithRange:NSMakeRange(i, 1)] intValue];
            nextRoom = [[[_maze Room:roomIndex] objectAtIndex:doorIndex] intValue];
            roomIndex = abs(nextRoom);
            valPos = [_roomCenterPos objectAtIndex:roomIndex];
            xEntryPos = [valPos CGPointValue].x;
            yEntryPos = [valPos CGPointValue].y;
        }
        [currTrapPos addObject:[NSValue valueWithCGPoint:CGPointMake(xEntryPos, yEntryPos)]];
        [_pathTrapsPos addObject:currTrapPos];
    }
    posMinX = posMinX - length*sqrt(3)/2 - 10;
    posMinY = posMinY - length - 10;
    posMaxX = posMaxX + length*sqrt(3)/2 + 10;
    posMaxY = posMaxY + length + 10;
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    _mazeRect = CGRectMake(posMinX*scale, posMinY*scale, (posMaxX-posMinX)*scale, (posMaxY-posMinY)*scale);
    _mazeRect = CGRectMake(posMinX, posMinY, (posMaxX-posMinX), (posMaxY-posMinY));
}

-(void)drawMaze {
    //动画显示路径
    [self showLinesAnimationBegin:0];
    [self drawTraps];
}

-(void)drawTraps {
    if (_pathTrapsPos.count>0) {
        //画陷阱路线
        NSDictionary *mazeDict = [HoneyComb getObjectFromJson:self.MazeData];
        NSDictionary *traps = [mazeDict objectForKey:@"Traps"];
        _lindex = 0;
        double totalLength = [[[traps allValues] componentsJoinedByString:@""] length];
        double totalDuration = MIN(totalLength/10.0, kDuration);
        _timeDrawLineDuration =  [_pathTrapsPos[_lindex] count]/totalLength * totalDuration;
        //NSLog(@"Duration: %f at %d/%f, %f",_timeDrawLineDuration, [_pathTrapsPos[_lindex] count], totalLength, totalDuration);
        [self showLinesAnimationBegin:1]; //Trap
    }
}

-(AIHexagonView*)drawRoom:(CGPoint)centerPostion edgeLength:(int)length roomNumber:(int)roomNumber {
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
    roomView.showRoomNumber = _showRoomNumber;
    roomView.RoomNumber = roomNumber;
    roomView.EdgeLength = length;
    if (roomNumber==_currentRoomNumber && _currentRoomNumber>0 && _currentRoomNumber<=_roomTotalCount && _currentRoomNumber!=INT_ENTRYROOM) {
        [roomView setCurrentRoom];
    }
    [roomView setBackgroundColor:COLOR_CANNOTINROOM];
    [self.view addSubview:roomView];
    return roomView;
}

- (void)showLinesAnimationBegin:(int)PathOrTrap
{
    //PathOrTrap: 0:画路径 >0:画陷阱
    //添加path的UIView
    ShapeView  *pathShapeView = [[ShapeView alloc] init];
    pathShapeView.backgroundColor = [UIColor clearColor];
    pathShapeView.opaque = NO;
    pathShapeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pathShapeView];
    
    //设置线条的颜色
    UIColor *pathColor = [UIColor blueColor];
    if (PathOrTrap>0) {
        pathColor = [UIColor redColor];
    }
    pathShapeView.shapeLayer.fillColor = nil;
    pathShapeView.shapeLayer.strokeColor = pathColor.CGColor;

    //创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    if (PathOrTrap>0) {
        animation.delegate = self;
    }
    animation.duration = _timeDrawLineDuration;
    [pathShapeView.shapeLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [self updatePathsWithPathShapeView:pathShapeView PathOrTrap:PathOrTrap];
}

- (void)updatePathsWithPathShapeView:(ShapeView *)pathShapeView PathOrTrap:(int)PathOrTrap
{
    if (PathOrTrap==0) { //Path
        if ([_pathRoomPos count] >= 2) {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:[[_pathRoomPos firstObject] CGPointValue]];
            //设置路径的颜色和动画
            CGPoint point = [[_pathRoomPos firstObject] CGPointValue];
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [_pathRoomPos count] - 1)];
            [_pathRoomPos enumerateObjectsAtIndexes:indexSet
                                            options:0
                                         usingBlock:^(NSValue *pointValue, NSUInteger idx, BOOL *stop) {
                                             [path addLineToPoint:[pointValue CGPointValue]];
                                             [path appendPath:[UIBezierPath bezierPathWithArcCenter:[pointValue CGPointValue] radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
                                         }];
            path.usesEvenOddFillRule = YES;
            pathShapeView.shapeLayer.path = path.CGPath;
        } else {
            pathShapeView.shapeLayer.path = nil;
        }
    } else { //Trap
        if ([_pathTrapsPos[_lindex] count] >= 2) {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:[[_pathTrapsPos[_lindex] firstObject] CGPointValue]];
            //设置路径的颜色和动画
            CGPoint point = [[_pathTrapsPos[_lindex] firstObject] CGPointValue];
            [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [_pathTrapsPos[_lindex] count] - 1)];
            [_pathTrapsPos[_lindex] enumerateObjectsAtIndexes:indexSet
                                            options:0
                                         usingBlock:^(NSValue *pointValue, NSUInteger idx, BOOL *stop) {
                                             [path addLineToPoint:[pointValue CGPointValue]];
                                             [path appendPath:[UIBezierPath bezierPathWithArcCenter:[pointValue CGPointValue] radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
                                         }];
            path.usesEvenOddFillRule = YES;
            pathShapeView.shapeLayer.path = path.CGPath;
        }
    }
}

#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _lindex++;
    if (_lindex == [_pathTrapsPos count]) {
        _lindex = 0;
        return;
    }
    NSDictionary *maze = [HoneyComb getObjectFromJson:self.MazeData];
    NSDictionary *traps = [maze objectForKey:@"Traps"];
    double totalLength = [[[traps allValues] componentsJoinedByString:@""] length];
    double totalDuration = MIN(totalLength/10.0, kDuration);
    _timeDrawLineDuration =  [_pathTrapsPos[_lindex] count]/totalLength * totalDuration;
    //NSLog(@"Duration: %f at %d/%f, %f",_timeDrawLineDuration, [_pathTrapsPos[_lindex] count], totalLength, totalDuration);
    [self showLinesAnimationBegin:2];
}

@end
