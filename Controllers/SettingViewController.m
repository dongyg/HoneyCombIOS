//
//  MoreViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "SettingViewController.h"
#import "AIHexagonView.h"
#import "SqliteDatabase.h"
#import "PurchaseViewController.h"
#import "SpinnerFactory.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "QQSessionActivity.h"
#import "QQZoneActivity.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(purchaseDone) name:@"purchaseDone" object:nil];
    self.tableView.rowHeight = 44.0f;

    [self showCurrentSetting];
    _levelPicker = [[LevelPickerView alloc] init];
    _levelPicker.delegate = self;

    [self.view setBackgroundColor:COLOR_BACKGROUND];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self showCurrentSetting];
}

- (IBAction)backButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)purchaseDone {
    NSMutableArray *arrTemp1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameBeeEyesRooms"];
    NSMutableArray *arrTemp2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeBeeEyesRooms"];
    int consumeCount = arrTemp1.count+arrTemp2.count;
    if (consumeCount>0) {
        self.labelBeyes.text = [NSString stringWithFormat:@"%d(-%d)", [[SqliteDatabase database] getBeeEyeRetain], consumeCount];
    } else {
        self.labelBeyes.text = [NSString stringWithFormat:@"%d", [[SqliteDatabase database] getBeeEyeRetain]];
    }
}

- (void)showCurrentSetting {
    NSInteger currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentLevel"];
    NSInteger currentStage = [[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentStage"];
    if (!currentLevel) {
        currentLevel = 1;
    }
    if (!currentStage) {
        currentStage = 1;
    }
    self.labelLevelDetail.text = [NSString stringWithFormat:@"%d - %d",(int)currentLevel,(int)currentStage];
    //
    NSMutableArray *arrTemp1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"GameBeeEyesRooms"];
    NSMutableArray *arrTemp2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeBeeEyesRooms"];
    int consumeCount = arrTemp1.count+arrTemp2.count;
    if (consumeCount>0) {
        self.labelBeyes.text = [NSString stringWithFormat:@"%d(-%d)", [[SqliteDatabase database] getBeeEyeRetain], consumeCount];
    } else {
        self.labelBeyes.text = [NSString stringWithFormat:@"%d", [[SqliteDatabase database] getBeeEyeRetain]];
    }
    [self.swOpenEyes setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"OpenBeeEyes"]];
}

- (void)getProductInfo {
    NSSet * set = [NSSet setWithArray:@[@"honeycomb.beyes.1", @"honeycomb.beyes.3", @"honeycomb.beyes.6", @"honeycomb.beyes12"]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0 && indexPath.row==0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_levelPicker showInView:self.view];
    } else if (indexPath.section==1 && indexPath.row==1) {
        [SpinnerFactory EnterWaiting:self.view];
        if ([SKPaymentQueue canMakePayments]) {
            [self getProductInfo];
        } else {
            NSLog(@"用户禁止应用内付费购买.");
        }
    } else if (indexPath.section==1 && indexPath.row==2) {
        //NSLog(@"View Bee-Eyes details.");
    } else if (indexPath.section==2 && indexPath.row==0) {
        //NSLog(@"Share to ...");
        UIImage *imageQRwww = [UIImage imageNamed:@"SuperBrainClassic.png"];
        NSString *postText = [NSString stringWithFormat:@"%@",NSLocalizedString(STRING_SHARETEXT,nil)];
        NSURL *urlToShare = [NSURL URLWithString:STRING_SHAREURL];
        NSArray *activityItems = @[postText, imageQRwww, urlToShare];
        //添加微信、QQ分享
        NSArray* activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init], [[QQSessionActivity alloc] init], [[QQZoneActivity alloc] init]];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                 applicationActivities:activity];
        activityVC.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypeAddToReadingList, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, nil];
        
        if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            activityVC.popoverPresentationController.sourceView = cell;
            activityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        }
        [activityVC setCompletionHandler:^(NSString *act, BOOL done)
        {
            NSString *ServiceMsg = @"Once";
            if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @ "Facebook";
            if ( [act isEqualToString:UIActivityTypePostToTwitter] ) ServiceMsg = @ "Twitter";
            if ( [act isEqualToString:UIActivityTypePostToWeibo] ) ServiceMsg = @ "SinaWeibo";
            if ( [act isEqualToString:UIActivityTypeMessage] ) ServiceMsg = @ "Message";
            if ( [act isEqualToString:UIActivityTypeMail] ) ServiceMsg = @ "Mail";
            if ( [act isEqualToString:UIActivityTypePostToFlickr] ) ServiceMsg = @ "Flickr";
            if ( [act isEqualToString:UIActivityTypePostToVimeo] ) ServiceMsg = @ "Vimeo";
            if ( [act isEqualToString:UIActivityTypePostToTencentWeibo] ) ServiceMsg = @ "TencentWeibo";
            if ( [act isEqualToString:@"WeixinTimelineActivity"] ) ServiceMsg = @ "WeixinTimeline";
            if ( [act isEqualToString:@"WeixinSessionActivity"] ) ServiceMsg = @ "WeixinSession";
            if ( [act isEqualToString:@"QQSessionActivity"] ) ServiceMsg = @ "QQSession";
            if ( [act isEqualToString:@"QQZoneActivity"] ) ServiceMsg = @ "QQZone";
            if ( done && act) {
                if ([act isEqualToString:@"WeixinTimelineActivity"] || [act isEqualToString:@"WeixinSessionActivity"] || [act isEqualToString:@"QQSessionActivity"] || [act isEqualToString:@"QQZoneActivity"]) {
                    //微信、QQ分享需要等待返回
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(STRING_BEYE_AWARD,nil), ServiceMsg] forKey:@"ShareSummary"];
                    [[NSUserDefaults standardUserDefaults] setInteger:100 forKey:@"ShareNumber"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                } else {
                    //其他iOS系统内的完成后即为分享成功
                    int setnum = [[SqliteDatabase database] UpdateBeeEyeNumber:100 summary:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(STRING_BEYE_AWARD,nil), ServiceMsg]];
                    if (setnum>0) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"purchaseDone" object:nil];
                        UIAlertView *alertView = [[UIAlertView alloc]
                                                  initWithTitle:NSLocalizedString(@"Share",nil)
                                                  message:NSLocalizedString(@"ShareSuccessOnce",nil)
                                                  delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }
                NSLog(@"Share Done. %@",act);
            } else {
                NSLog(@"Share Cancel. %@",act);
            }
        }];
        [self presentViewController:activityVC animated:YES completion:nil];
    } else if (indexPath.section==3 && indexPath.row==0) {
        //评论
        //NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=979088936";
        NSString *url = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=979088936&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark - LevelPickerDelegate

-(void)pickerDidChaneStatus:(LevelPickerView *)picker
{
    [self showCurrentSetting];
}

- (IBAction)clickSwitchEyes:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.swOpenEyes.isOn forKey:@"OpenBeeEyes"];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
//    for (SKProduct* aProduct in myProduct) {
//        NSLog(@"%@",aProduct.productIdentifier);
//        NSLog(@"%@",aProduct.localizedTitle);
//        NSLog(@"%@",aProduct.localizedDescription);
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [numberFormatter setLocale:aProduct.priceLocale];
//        NSString *formattedString = [numberFormatter stringFromNumber:aProduct.price];
//        NSLog(@"%@",formattedString);
//    }
    if (myProduct.count == 0) {
        NSLog(@"无内购产品信息！");
    } else {
        [SpinnerFactory LeaveWaiting:self.view];
        PurchaseViewController *purchaseView = [[PurchaseViewController alloc] init];
        purchaseView.purchaseProducts = [[NSMutableArray alloc] initWithArray:myProduct];
        [self.navigationController pushViewController:purchaseView animated:YES];
        //[self.navigationController presentViewController:purchaseView animated:YES completion:nil];
    }
}

@end
