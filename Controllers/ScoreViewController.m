//
//  ScoreViewController.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/3/1.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "ScoreViewController.h"
#import "AIHexagonView.h"
#import "MazeViewController.h"
#import "SqliteDatabase.h"
#import "ChallengeCell.h"
#import "UIButton+Bootstrap.h"

@interface ScoreViewController ()

@end

@implementation ScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *scores1 = [[SqliteDatabase database] ListGameScore];
    _scoreData = [[NSMutableArray alloc] initWithArray:scores1];
    NSMutableArray *scores2 = [[SqliteDatabase database] ListChallengeScore];
    [_scoreData addObjectsFromArray:scores2];
    self.tableView.rowHeight = 44.0f;
//    [self.view setBackgroundColor:COLOR_BACKGROUND];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickViewMaze:(NSString*)mazeData starTotal:(int)starTotal starGot:(int)starGot timeText:(NSString*)timeText steps:(NSString*)steps stageTitle:(NSString*)stageTitle
{
    MazeViewController *view = [[MazeViewController alloc] init];
    view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    view.StarGot = starGot;
    view.StarTotal = starTotal;
    view.MazeData = mazeData;
    view.timeText = timeText;
    view.Steps = steps;
    view.showRoomNumber = NO;
    view.showShareButton = YES;
    view.StageTitle = stageTitle;
    [self presentViewController:view animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _scoreData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScoreCell";
    ChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChallengeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *row = [_scoreData objectAtIndex:indexPath.row];
    if ([[row allKeys] containsObject:@"Level"]) {
        int level = [[row objectForKey:@"Level"] intValue];
        int stage = [[row objectForKey:@"Stage"] intValue];
        cell.labelTitle.text = [NSString stringWithFormat:@"%d - %d",level,stage];
    } else if ([[row allKeys] containsObject:@"Name"]) {
        cell.labelTitle.text = [row objectForKey:@"Name"];
    }
    
    double stime = [[row objectForKey:@"SpentTime"] doubleValue];
    int ms = lround(floor(stime * 100)) % 100;
    int second = lround(floor(stime/1.)) % 60;
    int minute = lround(floor(stime/60.)) % 60;
    int hours = lround(floor(stime/3600.)) % 100;
    NSString *retval = [NSString stringWithFormat:@"%02d:%02d:%02d.%02d",hours,minute,second,ms];
    cell.labelDetail.text = retval;
    
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

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *row = [_scoreData objectAtIndex:indexPath.row];
    NSString* stageTitle = @"";
    if ([[row allKeys] containsObject:@"Level"]) {
        int level = [[row objectForKey:@"Level"] intValue];
        int stage = [[row objectForKey:@"Stage"] intValue];
        stageTitle = [NSString stringWithFormat:@"%d - %d",level,stage];
    } else if ([[row allKeys] containsObject:@"Name"]) {
        stageTitle = [row objectForKey:@"Name"];
    }
    double stime = [[row objectForKey:@"SpentTime"] doubleValue];
    int ms = lround(floor(stime * 100)) % 100;
    int second = lround(floor(stime/1.)) % 60;
    int minute = lround(floor(stime/60.)) % 60;
    int hours = lround(floor(stime/3600.)) % 100;
    NSString *steps = [row objectForKey:@"Steps"];
    NSString *retval = [NSString stringWithFormat:@"%02d:%02d:%02d.%02d",hours,minute,second,ms];
    //if ([row objectForKey:@"MazeData"] && [row objectForKey:@"Level"]) {
    if ([row objectForKey:@"MazeData"]) {
        //NSLog(@"%@",[row objectForKey:@"MazeData"]);
        int starcount = [[row objectForKey:@"StarCount"] intValue];
        NSDictionary *mazeDict = [HoneyComb getObjectFromJson:[row objectForKey:@"MazeData"]];
        NSArray *_starRooms = [[NSMutableArray alloc] initWithArray:[mazeDict objectForKey:@"Stars"]];
        [self clickViewMaze:[row objectForKey:@"MazeData"] starTotal:_starRooms.count starGot:starcount timeText:retval steps:steps stageTitle:stageTitle];
    }
}

@end
