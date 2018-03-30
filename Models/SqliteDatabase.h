//
//  SqliteDatabase.h
//  exSQLite
//
//  Created by dongyiguang on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqliteDatabase : NSObject {
    sqlite3 *_database;
}

+ (SqliteDatabase*)database;

-(void)AddGameScore:(int)Level stage:(int)Stage spentTime:(double)SpentTime starCount:(int)StarCount mazeData:(NSString*)MazeData steps:(NSString*)steps;
-(void)AddChallengeScore:(NSString*)cid cname:(NSString*)cname spentTime:(double)SpentTime starCount:(int)StarCount mazeData:(NSString*)MazeData steps:(NSString*)steps;

- (NSMutableArray *)ListGameScore;
- (NSMutableArray *)ListChallengeScore;

- (NSMutableDictionary *)ListPassedLevalAndStage;

-(int)getBeeEyeRetain;
-(int)UpdateBeeEyeNumber:(int)plusNumber summary:(NSString*)summary;
- (NSMutableArray *)ListBeeEyes;

@end
