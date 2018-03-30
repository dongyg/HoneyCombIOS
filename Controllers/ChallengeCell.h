//
//  ChallengeCell.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/16.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelLevel;
@property (weak, nonatomic) IBOutlet UILabel *labelDetail;
@property (weak, nonatomic) IBOutlet UILabel *labelStars;
@end
