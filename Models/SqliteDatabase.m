//
//  SqliteDatabase.m
//  exSQLite
//
//  Created by dongyiguang on 13-3-15.
//
//

#import "SqliteDatabase.h"
#import "Consts.h"

@implementation SqliteDatabase

static SqliteDatabase *_database;

+(SqliteDatabase*)database {
    if (_database == nil) {
        _database = [[SqliteDatabase alloc] init];
    }
    return _database;
}

-(id)init {
    if (self = [super init]) {
        //初始化时打开数据库
        //获取数据库文件路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *sqLiteDb = [documentsDirectory stringByAppendingPathComponent:@"score.db"];
        NSLog(@"db path: %@",sqLiteDb); //查看数据库文件路径
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exists = [fileManager fileExistsAtPath:sqLiteDb]; //判断数据库文件是否存在
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        if (!exists) {
            //数据库文件不存在时，创建库表结构
            NSLog(@"Create database...");
            //创建数据库表
            NSString *createSQL = @"create table scores(id text,level int,stage int,stime int,starcount int,mazedata text); create table challscore(id text,name text,stime int,starcount int,mazedata text);";
            char *errorMsg;
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(_database);
                NSLog(@"Create database error: %s",errorMsg);
            } else {
                //初始化数据
                NSLog(@"Initialize data...");
                //NSString *insertSQL = @"insert into users(usercode,username,logopng,server) values('ENFO','盈丰','enfo.png','www.enfo.com.cn:8084')";
                //sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg);
            }
        }
        //数据库存在时，判断表存在与否进行数据库升级
        //版本管理
        NSInteger dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"DatabaseVersion"];
        NSLog(@"Database Version: %d",dbVersion);
        //100及以下版本
        if (dbVersion<101) {
            //添加beyes和beyeretain表
            NSString *createSQL = @"create table beyes(id text,occurtime datetime,plusnum int,summary text);";
            char *errorMsg;
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                NSLog(@"Create table [beyes] error: %s",errorMsg);
            }
            createSQL = @"create table beyeretain(beyenum int);";
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                NSLog(@"Create table [beyeretain] error: %s",errorMsg);
            } else {
                NSString *insertSQL = @"insert into beyeretain(beyenum) values(99999999);";
                if (sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                    NSLog(@"Error: %s",errorMsg);
                }
            }
            //修改scores表结构
            createSQL = @"create table scores1(id text,level int,stage int,stime real,starcount int,mazedata text,steps text); insert into scores1(id,level,stage,stime,starcount,mazedata) select id,level,stage,stime,starcount,mazedata from scores; drop table scores; ALTER TABLE scores1 RENAME TO scores;";
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                NSLog(@"Alter table [scores] error: %s",errorMsg);
            }
            //修改challscore表结构
            createSQL = @"create table challscore1(id text,name text,stime int,starcount int,mazedata text,steps text); insert into challscore1(id,name,stime,starcount,mazedata) select id,name,stime,starcount,mazedata from challscore; drop table challscore; ALTER TABLE challscore1 RENAME TO challscore;";
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                NSLog(@"Alter table [challscore] error: %s",errorMsg);
            }
            //更新版本到101
            [[NSUserDefaults standardUserDefaults] setInteger:101 forKey:@"DatabaseVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (dbVersion<102) {
            //修改一些以前的数据
            NSString *createSQL = @"update beyes set summary=replace(summary,'Consume in game','Consume') where summary like 'C%';\
                                    update beyes set summary='Purchase' where summary like '%Purchase%' or summary like '%honeycomb.beyes%';";
            char *errorMsg;
            if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                NSLog(@"update error: %s",errorMsg);
            }
            //更新版本到102
            [[NSUserDefaults standardUserDefaults] setInteger:102 forKey:@"DatabaseVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return self;
}

-(void)dealloc {
    sqlite3_close(_database);
}

-(NSString *) gen_uuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(NSString*)CFBridgingRelease(uuid_string_ref)];
    
    return uuid;
}

-(BOOL)tableExists:(NSString *)tablename {
    BOOL retval = NO;
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) FROM sqlite_master WHERE type='table' AND name='%@'",tablename];
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retval = YES;
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"tableExists:sqlite3_prepare_v2 return: %d",ret);
    }
    if (!retval) {
        NSLog(@"Table [%@] is not exists!",tablename);
    } else {
        NSLog(@"Table [%@] is exists!",tablename);
    }
    return retval;
}

-(int)getBeeEyeRetain {
    //取可用eye个数
    int retval = 0;
    NSString *query = @"SELECT max(beyenum) FROM beyeretain;";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retval = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"getBeeEyeRetain:sqlite3_prepare_v2 return: %d",ret);
    }
    return retval>=0 ? retval : 0;
}

-(int)UpdateBeeEyeNumber:(int)plusNumber summary:(NSString*)summary {
    //记录eye变动
    if (plusNumber==0) return 0;
    BOOL exist = NO;
    if ([summary hasPrefix:NSLocalizedString(STRING_BEYE_AWARD,nil)] || [summary hasPrefix:NSLocalizedString(STRING_BEYE_GAMEGIFT,nil)]) {
        //赠送时，根据summary判断，过关赠送和分享赠送的，是否已经赠送，不重复赠送
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM beyes where summary='%@'",summary];
        sqlite3_stmt *statement;
        int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
        if ( ret == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                exist = YES;
            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"scoreExists:sqlite3_prepare_v2 return: %d",ret);
        }
    }
    //NSLog(@"%@:%d",summary,plusNumber);
    if (!exist) {
        //NSLog(@"Execute insert.");
        char *errorMsg;
        NSString *insertSQL;
        insertSQL = [NSString stringWithFormat:@"insert into beyes(id,occurtime,plusnum,summary) values('%@',date('now'),'%d','%@')",[self gen_uuid],plusNumber,summary];
        if (sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            NSLog(@"executeQuery Error: %s", errorMsg);
            sqlite3_free(errorMsg);
        } else {
            insertSQL = [NSString stringWithFormat:@"update beyeretain set beyenum=beyenum+(%d);",plusNumber];
            sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg);
        }
        return plusNumber;
    } else {
        return 0;
    }
}

- (NSMutableArray *)ListBeeEyes {
    //取蜂眼变动记录
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT id,occurtime,plusnum,summary FROM beyes order by occurtime desc;";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *idChars = (char *) sqlite3_column_text(statement, 0);
            NSString *sid = [[NSString alloc] initWithUTF8String:idChars];
            char *occurtimeChars = (char *) sqlite3_column_text(statement, 1);
            NSString *occurtime = [[NSString alloc] initWithUTF8String:occurtimeChars];
            int plusnum = sqlite3_column_int(statement, 2);
            char *summaryChars = (char *) sqlite3_column_text(statement, 3);
            NSString *summary = [[NSString alloc] initWithUTF8String:summaryChars];
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
                                 sid, @"id",
                                 [NSNumber numberWithInt:plusnum], @"plusnum",
                                 occurtime, @"occurtime",
                                 summary, @"summary",
                                 nil];
            [retval addObject:row];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"ListBeeEyes:sqlite3_prepare_v2 return: %d",ret);
    }
    return retval;
}

-(void)AddGameScore:(int)Level stage:(int)Stage spentTime:(double)SpentTime starCount:(int)StarCount mazeData:(NSString*)MazeData steps:(NSString*)steps{
    //保存闯关游戏成绩
    //先判断成绩是否存在
    BOOL exist = NO;
    double stime = 0;
    NSString *query = [NSString stringWithFormat:@"SELECT stime FROM scores where level='%d' and stage='%d'",Level,Stage];
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            stime = sqlite3_column_double(statement, 0);
            exist = YES;
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"scoreExists:sqlite3_prepare_v2 return: %d",ret);
    }
    //再保存
    char *errorMsg;
    NSString *insertSQL;
    if (!exist) {
        insertSQL = [NSString stringWithFormat:@"insert into scores(id,level,stage,stime,starcount,mazedata,steps) values('%@','%d','%d','%f','%d','%@','%@')",[self gen_uuid],Level,Stage,SpentTime,StarCount,MazeData,steps];
    } else if (stime==0 || SpentTime<stime) {
        insertSQL = [NSString stringWithFormat:@"update scores set stime='%f',starcount='%d',mazedata='%@',steps='%@' where level='%d' and stage='%d';",SpentTime,StarCount,MazeData,steps,Level,Stage];
    }
    //NSLog(@"%@",insertSQL);
    if (insertSQL && ![insertSQL isEqualToString:@""]) {
        if (sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
        {
            NSLog(@"executeQuery Error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
    }
}

-(void)AddChallengeScore:(NSString*)cid cname:(NSString*)cname spentTime:(double)SpentTime starCount:(int)StarCount mazeData:(NSString*)MazeData steps:(NSString*)steps{
    //判断本地挑战成绩是否存在
    BOOL exist = NO;
    double stime = 0;
    NSString *query = [NSString stringWithFormat:@"SELECT stime FROM challscore where id = '%@'",cid];
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            stime = sqlite3_column_double(statement, 0);
            exist = YES;
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"scoreExists:sqlite3_prepare_v2 return: %d",ret);
    }
    //保存本地挑战成绩，成绩更好时(时间更短)才保存
    char *errorMsg;
    NSString *insertSQL;
    if (!exist) {
        insertSQL = [NSString stringWithFormat:@"insert into challscore(id,name,stime,starcount,mazedata,steps) values('%@','%@','%f','%d','%@','%@')",cid,cname,SpentTime,StarCount,MazeData,steps];
    } else if (stime==0 || SpentTime<stime) {
        insertSQL = [NSString stringWithFormat:@"update challscore set stime='%f',starcount='%d',mazedata='%@',steps='%@' where id='%@'",SpentTime,StarCount,MazeData,steps,cid];
    }
    //NSLog(@"%@",insertSQL);
    if (insertSQL && ![insertSQL isEqualToString:@""]) {
        if (sqlite3_exec(_database, [insertSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
        {
            NSLog(@"executeQuery Error: %s", errorMsg);
            sqlite3_free(errorMsg);
        }
    }
}

- (NSMutableArray *)ListGameScore {
    //取闯关成绩列表
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT id,level,stage,stime,starcount,mazedata,steps FROM scores order by level desc,stage desc;";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *idChars = (char *) sqlite3_column_text(statement, 0);
            NSString *rowid = [[NSString alloc] initWithUTF8String:idChars];
            int level = sqlite3_column_int(statement, 1);
            int stage = sqlite3_column_int(statement, 2);
            double stime = sqlite3_column_double(statement, 3);
            int starcount = sqlite3_column_int(statement, 4);
            char *mazedataChars = (char *) sqlite3_column_text(statement, 5);
            char *stepsChars = (char *) sqlite3_column_text(statement, 6);
            NSString *mazedata = [[NSString alloc] initWithUTF8String:mazedataChars];
            NSString *steps;
            if (stepsChars == NULL)
                steps = nil;
            else
                steps = [[NSString alloc] initWithUTF8String:stepsChars];
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
                                 rowid, @"RowId",
                                 [NSNumber numberWithInt:level], @"Level",
                                 [NSNumber numberWithInt:stage], @"Stage",
                                 [NSNumber numberWithDouble:stime], @"SpentTime",
                                 [NSNumber numberWithInt:starcount], @"StarCount",
                                 mazedata, @"MazeData",
                                 steps, @"Steps",
                                 nil];
            [retval addObject:row];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"ListGameScore:sqlite3_prepare_v2 return: %d",ret);
    }
    return retval;
}

- (NSMutableArray *)ListChallengeScore {
    //取挑战成绩列表
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT id,name,stime,starcount,mazedata,steps FROM challscore;";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *idChars = (char *) sqlite3_column_text(statement, 0);
            NSString *rowid = [[NSString alloc] initWithUTF8String:idChars];
            char *nameChars = (char *) sqlite3_column_text(statement, 1);
            NSString *sname = [[NSString alloc] initWithUTF8String:nameChars];
            double stime = sqlite3_column_double(statement, 2);
            int starcount = sqlite3_column_int(statement, 3);
            char *mazedataChars = (char *) sqlite3_column_text(statement, 4);
            char *stepsChars = (char *) sqlite3_column_text(statement, 5);
            NSString *mazedata = [[NSString alloc] initWithUTF8String:mazedataChars];
            NSString *steps;
            if (stepsChars == NULL)
                steps = nil;
            else
                steps = [[NSString alloc] initWithUTF8String:stepsChars];
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:
                                 rowid, @"Id",
                                 sname, @"Name",
                                 [NSNumber numberWithDouble:stime], @"SpentTime",
                                 [NSNumber numberWithInt:starcount], @"StarCount",
                                 mazedata, @"MazeData",
                                 steps, @"Steps",
                                 nil];
            [retval addObject:row];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"ListChallengeScore:sqlite3_prepare_v2 return: %d",ret);
    }
    return retval;
}

- (NSMutableDictionary *)ListPassedLevalAndStage {
    //取已经通过的闯关关卡level-stage
    //目前没有用
    NSString *query = @"SELECT level,stage FROM scores group by level,stage order by level,stage;";
    sqlite3_stmt *statement;
    int level = 0;
    int stage = 0;
    NSMutableDictionary *levels = [NSMutableDictionary dictionary];
    NSMutableArray *stages;
    int ret = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if ( ret == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int l = sqlite3_column_int(statement, 0);
            if (l!=level) {
                if (stages) {
                    [levels setValue:stages forKey:[NSString stringWithFormat:@"%d",level]];
                }
                stages = [[NSMutableArray alloc] init];
                level = l;
            }
            stage = sqlite3_column_int(statement, 1);
            [stages addObject:[NSString stringWithFormat:@"%d",stage]];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"ListPassedLevalAndStage:sqlite3_prepare_v2 return: %d",ret);
    }
    return levels;
}

@end
