//
//  LevelPickerView.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/14.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LevelPickerView;

@protocol LevelPickerDelegate <NSObject>

@optional
- (void)pickerDidChaneStatus:(LevelPickerView *)picker;

@end

@interface LevelPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource> {
    int _level;
    int _stage;
    NSMutableDictionary* dicPicker;
    NSMutableArray *pickerArray;
    NSMutableArray *subPickerArray;
}

@property (assign, nonatomic) id <LevelPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction)clickOk:(id)sender;
- (IBAction)clickCancel:(id)sender;
- (void)showInView:(UIView *)view;
- (void)cancelPicker;

@end
