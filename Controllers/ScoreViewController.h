//
//  ScoreViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoneyComb.h"

@interface ScoreViewController : UITableViewController {
    NSMutableArray *_scoreData;
}

- (IBAction)backButtonTap:(id)sender;

@end
