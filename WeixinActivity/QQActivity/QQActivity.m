//
//  QQActivity.m
//  QQActivity

#import "QQActivity.h"
#import "Consts.h"

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
    NSString *previewImageUrl = [NSString stringWithFormat:@"%@/static/img/pages/img1.png",STRING_SHAREURL];
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:url title:title description:title previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent = EQQAPIQQNOTSUPPORTAPI;
    if (scene==QQSceneSession) {
        //将内容分享到qq
        sent = [QQApiInterface sendReq:req];
    } else if (scene==QQSceneZone) {
        //将内容分享到qzone
        sent = [QQApiInterface SendReqToQZone:req];
    }
    //NSLog(@"%d",sent);
    //分享调起QQ后返回EQQAPIAPPSHAREASYNC=7
    if (sent==EQQAPIAPPSHAREASYNC) {
        [self activityDidFinish:YES];
    } else {
        [self activityDidFinish:NO];
    }
}

@end
