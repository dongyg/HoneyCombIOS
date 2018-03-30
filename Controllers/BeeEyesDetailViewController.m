//
//  BeeEyesDetailViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/4/17.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "BeeEyesDetailViewController.h"
#import "SqliteDatabase.h"
#import "BeeEyesDetailCell.h"

@interface BeeEyesDetailViewController ()

@end

@implementation BeeEyesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 44.0f;
    self.navigationItem.title = NSLocalizedString(@"Bee-eyes detail", nil);
    NSMutableArray *scores1 = [[SqliteDatabase database] ListBeeEyes];
    _BeyesDetailData = [[NSMutableArray alloc] initWithArray:scores1];
    [self filterData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)filterData
{
    NSString *searchText = self.searchbar.text;
    [_filterData removeAllObjects];
    if (searchText == nil || [searchText isEqualToString:@""]) {
        _filterData = [[NSMutableArray alloc] initWithArray:_BeyesDetailData];
    } else {
        for (NSDictionary *loop in _BeyesDetailData) {
            NSString *t1 = [loop objectForKey:@"summary"];
            if ([t1 rangeOfString:searchText].location != NSNotFound) {
                [_filterData addObject:loop];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _filterData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BeeEyesDetailCell";
    BeeEyesDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BeeEyesDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *row = [_filterData objectAtIndex:indexPath.row];
    cell.labelTitle.text = [row objectForKey:@"summary"];
    cell.labelNumber.text = [NSString stringWithFormat:@"%d",[[row objectForKey:@"plusnum"] intValue]];
    cell.labelTime.text = [row objectForKey:@"occurtime"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    //self.navigationController.navigationBar.hidden = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    //self.navigationController.navigationBar.hidden = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterData];
    [self.tableView reloadData];
}

@end
