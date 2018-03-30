//
//  BeeEyesDetailViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/4/17.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeEyesDetailViewController : UITableViewController <UISearchBarDelegate> {
    NSMutableArray *_BeyesDetailData;
    NSMutableArray* _filterData;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@end
