//
//  QQZoneActivity.m
//  QQActivity

#import "QQZoneActivity.h"

@implementation QQZoneActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = QQSceneZone;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_qqzone.png"];
}

- (NSString *)activityTitle
{
    return @"QQ空间";
}

@end
