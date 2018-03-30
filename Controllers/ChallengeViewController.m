//
//  ChallengeViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/15.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "ChallengeViewController.h"
#import "WalkingViewController.h"
#import "UIButton+Bootstrap.h"
#import "ChallengeCell.h"

@interface ChallengeViewController ()

@end

@implementation ChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //取本地挑战关卡
    NSString *path = [[NSBundle mainBundle] pathForResource:@"challenge.json" ofType:nil];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"stages.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    _jsonArray =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initData];
    [self.tableView reloadData];
}

- (void)initData {
    //取已完成的挑战的成绩
    NSMutableArray *scores2 = [[SqliteDatabase database] ListChallengeScore];
    NSMutableDictionary *scores = [[NSMutableDictionary alloc] init];
    for (int i=0; i<scores2.count; i++) {
        NSDictionary *row = [scores2 objectAtIndex:i];
        [scores setValue:row forKey:[row objectForKey:@"Id"]];
    }
    _ChallengeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeId"];
    int currPos = 0;
    for (int i=0; i<_jsonArray.count; i++) {
        NSDictionary *row = [_jsonArray objectAtIndex:i];
        if ([scores objectForKey:[row objectForKey:@"Id"]]) {
            [row setValue:[[scores objectForKey:[row objectForKey:@"Id"]] objectForKey:@"SpentTime"] forKey:@"SpentTime"];
            [row setValue:[[scores objectForKey:[row objectForKey:@"Id"]] objectForKey:@"StarCount"] forKey:@"StarCount"];
            [row setValue:[[scores objectForKey:[row objectForKey:@"Id"]] objectForKey:@"MazeData"] forKey:@"MazeData"];
            [row setValue:[[scores objectForKey:[row objectForKey:@"Id"]] objectForKey:@"Steps"] forKey:@"Steps"];
            [_jsonArray replaceObjectAtIndex:i withObject:row];
        }
        if (_ChallengeId && [_ChallengeId isEqualToString:[row objectForKey:@"Id"]]) {
            currPos = i;
        }
    }
    //把正在挑战关卡拿到数组最上面
    while (currPos>0) {
        [_jsonArray exchangeObjectAtIndex:currPos withObjectAtIndex:currPos-1];
        currPos--;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _jsonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChallengeCell";
    ChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChallengeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *row = [_jsonArray objectAtIndex:indexPath.row];
    cell.labelTitle.text = [row objectForKey:@"Name"];
    int level = [[[row objectForKey:@"Maze"] objectForKey:@"Level"] intValue];
    cell.labelLevel.text = [NSString stringWithFormat:@"%d layers",level];
    if (_ChallengeId && [_ChallengeId isEqualToString:[row objectForKey:@"Id"]]) {
        //挑战中的
        NSString* spentTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeSpentTime"];
        int stime = [spentTime intValue];
        int second = stime  % 60;
        int minute = (stime / 60) % 60;
        int hours = stime / 3600;
        NSString *retval = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minute,second];
        cell.labelDetail.text = [NSString stringWithFormat:NSLocalizedString(@"Playing %@",nil),retval];
        cell.labelStars.text = @"";
    } else {
        //除正在挑战外的
        if ([row objectForKey:@"SpentTime"]) {
            double stime = [[row objectForKey:@"SpentTime"] doubleValue];
            int ms = lround(floor(stime * 100)) % 100;
            int second = lround(floor(stime/1.)) % 60;
            int minute = lround(floor(stime/60.)) % 60;
            int hours = lround(floor(stime/3600.)) % 100;
            NSString *retval = [NSString stringWithFormat:@"%02d:%02d:%02d.%02d",hours,minute,second,ms];
            cell.labelDetail.text = [NSString stringWithFormat:@"%@",retval];
            //
            int starcount = [[row objectForKey:@"StarCount"] intValue];
            NSString *title = @"";
            NSString *steps = [row objectForKey:@"Steps"];
            if (steps && steps.length>0) {
                title = [NSString stringWithFormat:NSLocalizedString(@"StepsTip",nil),steps.length];
            }
            NSString *iconStarGot = [NSString stringFromAwesomeIcon:FAIconStar];
            for (int i=0; i<starcount; i++) {
                title = [NSString stringWithFormat:@"%@%@", title,iconStarGot];
            }
            if ([row objectForKey:@"MazeData"]) {
                NSString *iconStarEmpty = [NSString stringFromAwesomeIcon:FAIconStarEmpty];
                NSDictionary *mazeDict = [HoneyComb getObjectFromJson:[row objectForKey:@"MazeData"]];
                NSArray *_starRooms = [[NSMutableArray alloc] initWithArray:[mazeDict objectForKey:@"Stars"]];
                for (int i=1; i<=_starRooms.count-starcount; i++) {
                    title = [NSString stringWithFormat:@"%@%@", title,iconStarEmpty];
                }
            }
            cell.labelStars.text = title;
        } else {
            cell.labelDetail.text = @"";
            cell.labelStars.text = @"";
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *row = [_jsonArray objectAtIndex:indexPath.row];

    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChallengeId"];
    //如果其它挑战进行中
    if (cid && ![cid isEqualToString:@""] && ![cid isEqualToString:[row objectForKey:@"Id"]]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeBeeEyesRooms"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeRoomNo"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeSpentTime"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChallengeGotStars"];
    }
    //
    WalkingViewController *view = [[WalkingViewController alloc] init];
    view.MazeData = [HoneyComb getJsonString:[row objectForKey:@"Maze"]];
    view.IsChallenge = YES;
    view.ChallengeName = [row objectForKey:@"Name"];
    view.ChallengeId = [row objectForKey:@"Id"];
//    [self.navigationController pushViewController:view animated:YES];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)backButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
