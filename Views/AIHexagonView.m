//
//  WalkingViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//
//  http://blog.csdn.net/iunion/article/details/26221213 这篇写的很细很规矩

#import "AIHexagonView.h"
#import "UIButton+Bootstrap.h"

@implementation AIHexagonView
@synthesize RoomNumber = _RoomNumber;
@synthesize FromDoor = _FromDoor;
@synthesize EdgeLength = _EdgeLength;
@synthesize IsStarRoom = _IsStarRoom;
@synthesize showRoomNumber = _showRoomNumber;
@synthesize room0 = _room0, room1 = _room1, room2 = _room2, room3 = _room3, room4 = _room4, room5 = _room5;

+(CGPathRef)pathFromPoints:(NSArray*)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[[points objectAtIndex:0] CGPointValue]];
    
    NSInteger count = points.count;
    for (NSInteger i = 1; i<count; i++)
    {
        [path addLineToPoint:[[points objectAtIndex:i] CGPointValue]];
    }    
    [path closePath];
    
    return CGPathCreateCopy(path.CGPath);
}

-(id)initWithPoints:(NSArray*)points
{
    CGPathRef path = [AIHexagonView pathFromPoints:points];
    
    self = [super initWithFrame:CGPathGetBoundingBox(path)];
    
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        CGAffineTransform t = CGAffineTransformMakeTranslation(-CGRectGetMinX(self.frame), -CGRectGetMinY(self.frame));
        [[self layer] setPath:CGPathCreateCopyByTransformingPath(path, &t)];
        [[self layer] setFillMode:kCAFillRuleNonZero];
        [self setBackgroundColor:[UIColor whiteColor]];
        [[self layer] setStrokeColor:[UIColor darkGrayColor].CGColor];

        _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, _EdgeLength/2, _EdgeLength*sqrt(3), _EdgeLength)];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_labelTitle];
    }
    return self;
}

#pragma mark - Overrided methods.

+(Class)layerClass
{
    return [CAShapeLayer class];
}

-(CAShapeLayer*)layer
{
    return (CAShapeLayer*)[super layer];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [[self layer] setFillColor:backgroundColor.CGColor];

//    [[self layer] setStrokeColor:backgroundColor.CGColor];
}

-(UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:[[self layer] fillColor]];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGPathContainsPoint([[self layer] path], NULL, point, ([[self layer] fillRule] == kCAFillRuleEvenOdd)))
    {
        return [super hitTest:point withEvent:event];
    }
    else
    {
        return nil;
    }
    
}

-(void)setRoomNumber:(int)RoomNumber {
    _RoomNumber = RoomNumber;
    if (_showRoomNumber || SWITCH_DEBUG) {
        _labelTitle.text = [NSString stringWithFormat:@"%d",abs(_RoomNumber)];
    }
}

-(void)setTitle:(NSString*)title {
    _labelTitle.text = title;
}

-(void)setCurrentRoom {
    UIFont * fontTwo = [UIFont fontWithName:@"FontAwesome" size:_EdgeLength];
    [_labelTitle setTextColor:[UIColor redColor]];
    [_labelTitle setFont:fontTwo];
    NSString *iconString = [NSString stringFromAwesomeIcon:FAIconUser];
    _labelTitle.text = iconString;
}

-(void)setEdgeLength:(int)EdgeLength {
    _EdgeLength = EdgeLength;
    _labelTitle.frame = CGRectMake(0, _EdgeLength/2, _EdgeLength*sqrt(3), _EdgeLength);
    if (_showRoomNumber || SWITCH_DEBUG) {
        _labelTitle.font = [UIFont systemFontOfSize:_EdgeLength/2];
    }
}

-(void)setIsStarRoom:(BOOL)IsStarRoom {
    _IsStarRoom = IsStarRoom;
    if (_IsStarRoom) {
        UIFont * fontTwo = [UIFont fontWithName:@"FontAwesome" size:_EdgeLength];
        [_labelTitle setTextColor:[UIColor orangeColor]];
        [_labelTitle setFont:fontTwo];
        NSString *iconString = [NSString stringFromAwesomeIcon:FAIconStar];
        _labelTitle.text = iconString;
    } else {
        _labelTitle.text = @"";
    }
}

-(void)setShowRoomNumber:(BOOL)showRoomNumber
{
    _showRoomNumber = showRoomNumber;
    if (_showRoomNumber || SWITCH_DEBUG) {
        _labelTitle.text = [NSString stringWithFormat:@"%d",abs(_RoomNumber)];
    } else {
        _labelTitle.text = @"";
    }
}

@end
