//
//  QQSessionActivity.m
//  QQActivity

#import "QQSessionActivity.h"

@implementation QQSessionActivity

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_qq.png"];
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"QQSession",nil);
}

@end
