//
//  PurchaseViewController.h
//  HoneyCombIOS
//
//  Created by DongYigung on 15/4/13.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SqliteDatabase.h"

@interface PurchaseViewController : UITableViewController {
    SqliteDatabase *_database;
}

@property (nonatomic, copy) NSMutableArray *purchaseProducts;

@end
