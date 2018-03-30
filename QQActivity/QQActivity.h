//
//  QQActivity.h
//  QQActivity
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

enum QQScene {
    QQSceneSession  = 0,
    QQSceneZone = 1,
};

@interface QQActivity : UIActivity {
    NSString *title;
    UIImage *image;
    NSURL *url;
    enum QQScene scene;
}

@end
