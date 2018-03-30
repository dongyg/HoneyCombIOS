//
//  ChallengeViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/15.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeViewController : UITableViewController {
    NSMutableArray* _jsonArray;
    NSString* _ChallengeId;
}

- (IBAction)backButtonTap:(id)sender;
@end
