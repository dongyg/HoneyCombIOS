//
//  PurchaseViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/4/13.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "PurchaseViewController.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController
@synthesize purchaseProducts = _purchaseProducts;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = NSLocalizedString(@"Purchase",nil);
    
    _database = [SqliteDatabase database];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPurchaseProducts:(NSMutableArray *)purchaseProducts {
    if (_purchaseProducts != purchaseProducts) {
        _purchaseProducts = [purchaseProducts mutableCopy];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _purchaseProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    
    SKProduct* aProduct = _purchaseProducts[indexPath.row];
    cell.textLabel.text = aProduct.localizedTitle;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:aProduct.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:aProduct.price];
    cell.detailTextLabel.text = formattedString;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SKProduct* aProduct = _purchaseProducts[indexPath.row];
    SKPayment *payment = [SKPayment paymentWithProduct:aProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

@end
