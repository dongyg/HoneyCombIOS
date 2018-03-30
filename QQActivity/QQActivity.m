//
//  QQActivity.m
//  QQActivity

#import "QQActivity.h"

@implementation QQActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
    }
}

- (void)performActivity
{
    //分享图预览图URL地址
    NSString *previewImageUrl = @"http://combmaze.sinaapp.com/static/img/pages/img1.png";
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:url title:title description:title previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if (scene==QQSceneSession) {
        //将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    } else if () {
        //将内容分享到qzone
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    }

    [self activityDidFinish:YES];
}

@end
