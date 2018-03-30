//
//  MoreViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "HoneyComb.h"
#import "LevelPickerView.h"

@interface SettingViewController : UITableViewController <SKProductsRequestDelegate, LevelPickerDelegate> {
    LevelPickerView* _levelPicker;
}

- (IBAction)backButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelLevelDetail;
@property (weak, nonatomic) IBOutlet UILabel *labelBeyes;
@property (weak, nonatomic) IBOutlet UISwitch *swOpenEyes;

- (IBAction)clickSwitchEyes:(id)sender;
@end
