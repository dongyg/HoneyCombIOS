//
//  LevelPickerView.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/14.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "LevelPickerView.h"
#import "SqliteDatabase.h"

@implementation LevelPickerView
@synthesize delegate = _delegate;
@synthesize pickerView = _pickerView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"LevelPickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        int currentLevel = [[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentLevel"] intValue];
        int currentStage = [[[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentStage"] intValue];
        if (!currentLevel) {
            currentLevel = 1;
        }
        if (!currentStage) {
            currentStage = 1;
        }
        _level = currentLevel;
        _stage = currentStage;
        NSMutableDictionary *passed = [[SqliteDatabase database] ListPassedLevalAndStage];
        dicPicker = [[NSMutableDictionary alloc] initWithDictionary:passed];
        pickerArray = [[NSMutableArray alloc] init];
        for (int i = 1; i<=99; i++) {
            if ([dicPicker.allKeys containsObject:[NSString stringWithFormat:@"%d",i]]) {
                [pickerArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        subPickerArray = [dicPicker objectForKey:[NSString stringWithFormat:@"%d",_level]];
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 9; //return pickerArray.count;
            break;
        case 1:
            return 9; //return subPickerArray.count;
            break;
        default:
            return 9;
            break;
    }
}

//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    if (component == 0) {
//        subPickerArray = [dicPicker objectForKey:[pickerArray objectAtIndex:row]];
//        [pickerView selectRow:0 inComponent:1 animated:YES];
//        [pickerView reloadComponent:1];
//    }
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [NSString stringWithFormat:@"%d",(int)row+1];
            break;
        case 1:
            return [NSString stringWithFormat:@"%d",(int)row+1];
            break;
        default:
            return @"";
            break;
    }
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.superview.frame.size.width/2;
}

#pragma mark - animation

- (IBAction)clickOk:(id)sender {
    NSInteger selectedLevelIndex = [self.pickerView selectedRowInComponent:0];
    NSInteger selectedStageIndex = [self.pickerView selectedRowInComponent:1];
    if (selectedLevelIndex+1!=_level || selectedStageIndex+1!=_stage) {
        [[NSUserDefaults standardUserDefaults] setInteger:selectedLevelIndex+1 forKey:@"CurrentLevel"];
        [[NSUserDefaults standardUserDefaults] setInteger:selectedStageIndex+1 forKey:@"CurrentStage"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameBeeEyesRooms"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CacheMaze"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSpentTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameRoomNo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameGotStars"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GameSteps"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }
    [self cancelPicker];
}

- (IBAction)clickCancel:(id)sender {
    [self cancelPicker];
}

- (void)showInView:(UIView *) view
{
    CGRect fr = self.pickerView.frame;
    fr.size.width = self.frame.size.width;
    self.pickerView.frame = fr;
    self.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 260);
    [self.pickerView selectRow:_level-1 inComponent:0 animated:NO];
    [self.pickerView selectRow:_stage-1 inComponent:1 animated:NO];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, view.frame.size.width, 260);
    }];
    
}

- (void)cancelPicker
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, 260);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
}

@end
