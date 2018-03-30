//
//  HoneyComb.m
//  HoneyCombIOS
//
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import "HoneyComb.h"

@implementation HoneyComb

@synthesize Level=_Level;
@synthesize StartRoom=_StartRoom;
@synthesize DoorEntry=_DoorEntry;

+(id)getObjectFromJson:(NSString*)json {
    //json to NS
    NSError* error;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *retval = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
    return retval;
}

+(NSString*)getJsonString:(id)obj {
    //NS to json
    NSError* error;
    NSData* inputJData;
    NSString* inputJSON;
    if (obj) {
        inputJData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
        inputJSON = [[NSString alloc] initWithData:inputJData encoding:NSUTF8StringEncoding];
    }
    return inputJSON;
}

// Innternal

-(int) buildRooms {
//    int roomCount = 0;
//    for (int i=self.Level; i<2*self.Level; i++) { //(Leve=7)7..13
//        roomCount += i;
//        if (i<2*self.Level-1) {
//            roomCount += i;
//        }
//    }
    _rooms = [[NSMutableArray alloc] init];
    _starRooms = [[NSMutableArray alloc] init];
    //一个虚拟房间接入口房间，在房间数组的第0个
    NSMutableArray *roomEntry = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:0], nil]; //six doors
    [_rooms addObject:roomEntry];
    _edgeRoomNos = [[NSMutableArray alloc] init];
    int iLoop = 1;
    for (int i=self.Level; i<2*self.Level; i++) { //(Leve=7)7..13
        for (int j=1; j<=i; j++) { //1..i
            int d0=0, d1=0, d2=0, d3=0, d4=0, d5=0;
            if (j>1) {
                d4 = iLoop - 1;
                [_rooms[d4] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:iLoop]];
            }
            if (i>self.Level) {
                if (j<i) {
                    d0 = iLoop-i+1;
                    [_rooms[d0] replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:iLoop]];
                }
                if (j>1) {
                    d3 = iLoop-i;
                    [_rooms[d3] replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:iLoop]];
                }
            }
            NSMutableArray *room = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:d0],
                                    [NSNumber numberWithInt:d1],
                                    [NSNumber numberWithInt:d2],
                                    [NSNumber numberWithInt:d3],
                                    [NSNumber numberWithInt:d4],
                                    [NSNumber numberWithInt:d5], nil]; //six doors
            [_rooms addObject:room];
            if (i==self.Level || j==1 || j==i) {
                [_edgeRoomNos addObject:[NSNumber numberWithInt:iLoop]];
            }
            iLoop++;
        }
    }
    for (int i=2*self.Level-2; i>=self.Level; i--) { //(Leve=7)12..7
        for (int j=1; j<=i; j++) { //1..i
            int d0=0, d1=0, d2=0, d3=0, d4=0, d5=0;
            d3 = iLoop-i-1;
            [_rooms[d3] replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:iLoop]];
            d0 = iLoop-i;
            [_rooms[d0] replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:iLoop]];
            if (j>1) {
                d4 = iLoop - 1;
                [_rooms[d4] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:iLoop]];
            }
            NSMutableArray *room = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:d0],
                                    [NSNumber numberWithInt:d1],
                                    [NSNumber numberWithInt:d2],
                                    [NSNumber numberWithInt:d3],
                                    [NSNumber numberWithInt:d4],
                                    [NSNumber numberWithInt:d5], nil]; //six doors
            [_rooms addObject:room];
            if (i==self.Level || j==1 || j==i) {
                [_edgeRoomNos addObject:[NSNumber numberWithInt:iLoop]];
            }
            iLoop++;
        }
    }
    //一个虚拟房间接出口房间，在房间数组的最后一个
    NSMutableArray *roomExit = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0], nil]; //six doors
    [_rooms addObject:roomExit];
    return iLoop-1; //房间个数
}

// External

- (instancetype)initWithJsonData:(NSString*)jsonData
{
/* jsonData: {"Level":"2","StartRoom":"1","EntryDoor":"0","Path":"254","Traps":{"4":"1"},"Stars":[1]}
 */
    self = [super init];
    if (self) {
        NSDictionary *mazeDict = [HoneyComb getObjectFromJson:jsonData];
        int level = [[mazeDict objectForKey:@"Level"] intValue];
        [self setLevel:level];
        int startRoom = [[mazeDict objectForKey:@"StartRoom"] intValue];
        _StartRoom = startRoom;
        _DoorEntry = [[mazeDict objectForKey:@"EntryDoor"] intValue];
        NSString *mainPath = [mazeDict objectForKey:@"Path"];
        NSDictionary *trapPaths = [mazeDict objectForKey:@"Traps"];
        _rooms[startRoom][_DoorEntry] = [NSNumber numberWithInt:-INT_ENTRYROOM];
        _rooms[0][5-_DoorEntry] = [NSNumber numberWithInt:-startRoom];
        int roomIndex = startRoom; int nextRoom = 0;
        for(int i = 0; i < [mainPath length]; i++) {
            int doorIndex = [[mainPath substringWithRange:NSMakeRange(i, 1)] intValue];
            nextRoom = [_rooms[abs(roomIndex)][doorIndex] intValue];
            if (nextRoom==0) {
                nextRoom = (int)_rooms.count-1;
            }
            if (abs(nextRoom)>=(int)_rooms.count) {
                NSLog(@"Outbound: %d [%d-%d]",nextRoom,0,(int)_rooms.count);
                break;
            }
            [_rooms[abs(roomIndex)] replaceObjectAtIndex:doorIndex withObject:[NSNumber numberWithInt:-abs(nextRoom)]];
            [_rooms[abs(nextRoom)] replaceObjectAtIndex:5-doorIndex withObject:[NSNumber numberWithInt:-abs(roomIndex)]];
            roomIndex = nextRoom;
        }
        for (NSString * akey in trapPaths) {
            roomIndex = [akey intValue];
            mainPath = [trapPaths objectForKey:akey];
            for(int i = 0; i < [mainPath length]; i++) {
                int doorIndex = [[mainPath substringWithRange:NSMakeRange(i, 1)] intValue];
                nextRoom = [_rooms[abs(roomIndex)][doorIndex] intValue];
                if (nextRoom==0) {
                    nextRoom = (int)_rooms.count-1;
                }
                if (abs(nextRoom)>=(int)_rooms.count) {
                    NSLog(@"Outbound: %d [%d-%d]",nextRoom,0,(int)_rooms.count);
                    break;
                }
                [_rooms[abs(roomIndex)] replaceObjectAtIndex:doorIndex withObject:[NSNumber numberWithInt:-abs(nextRoom)]];
                [_rooms[abs(nextRoom)] replaceObjectAtIndex:5-doorIndex withObject:[NSNumber numberWithInt:-abs(roomIndex)]];
                roomIndex = nextRoom;
            }
        }
        _starRooms = [[NSMutableArray alloc] initWithArray:[mazeDict objectForKey:@"Stars"]];
    }
    return self;
}

-(void) setLevel:(int)newLevel {
    if (_Level != newLevel) {
        _Level = newLevel;
        _RoomCount = [self buildRooms];
    }
}

-(int) RoomCount {
    return _RoomCount;
}

-(NSMutableArray*) Room:(int)roomNumber {
    if (roomNumber>=0 && roomNumber<_rooms.count) {
        return _rooms[roomNumber];
    } else {
        NSMutableArray *room = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0],
                                [NSNumber numberWithInt:0], nil]; //six doors
        return room;
    }
}

-(int) getNextDoor:(int)currRoom {
    //1.找不通的房间；2.存在不通的房间就从中随机选一个；3.不存在不通的房间就在0-5号门随机选一个
    NSMutableArray *canChooseDoors = [[NSMutableArray alloc] init];
    for (int i=0; i<6; i++) { //0-5号门
        int nextRoomVal = abs([_rooms[currRoom][i] intValue]);
        BOOL notpass = ![_routePassedRooms objectForKey:[NSString stringWithFormat:@"%d",nextRoomVal]];
        notpass = notpass && (![_trapPassedRooms objectForKey:[NSString stringWithFormat:@"%d",nextRoomVal]]);
        if (notpass && nextRoomVal>0 && nextRoomVal<INT_ENTRYROOM && nextRoomVal!=_StartRoom && nextRoomVal!=_rooms.count-1) {
            [canChooseDoors addObject:[NSNumber numberWithInt:i]];
        }
    }
    if (canChooseDoors.count>0) {
        int idx = arc4random() % canChooseDoors.count;
        return [canChooseDoors[idx] intValue];
    } else {
        int rval = arc4random() % 6;
        return rval;
    }
}

-(void) generateRoute {
    //clear route. 将虚拟入口、虚拟出口、所有房间的门都关闭
    if (_route.count>0) {
        for (int i=0; i<_rooms.count; i++) {
            if (i==0 || i==_rooms.count-1) { //clear entry
                for (int j=0; j<6; j++) {
                    [_rooms[i] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:0]];
                }
            } else {
                for (int j=0; j<6; j++) {
                    int roomNo = abs([_rooms[i][j] intValue]);
                    if (roomNo==_rooms.count-1 || roomNo==INT_ENTRYROOM) {
                        roomNo = 0;
                    }
                    [_rooms[i] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:roomNo]];
                }
            }
        }
    }
    _route = [[NSMutableArray alloc] init];
    //the entry room
    _StartRoom = arc4random() % _edgeRoomNos.count;
    _StartRoom = [_edgeRoomNos[_StartRoom] intValue];
    NSMutableArray *edgeDoors = [[NSMutableArray alloc] init];
    NSMutableArray *linkDoors = [[NSMutableArray alloc] init];
    for (int i=0; i<6; i++) {
        int nextRoomNo = [_rooms[_StartRoom][i] intValue];
        if (nextRoomNo>0) {
            [linkDoors addObject:[NSNumber numberWithInt:i]];
        } else {
            [edgeDoors addObject:[NSNumber numberWithInt:i]];
        }
    }
    _routePassedRooms = [NSMutableDictionary dictionary];
    //[_passedRooms setObject:[NSString stringWithFormat:@"%d",_StartRoom] forKey:[NSString stringWithFormat:@"%d",_StartRoom]];
    //入口
    _DoorEntry = arc4random() % edgeDoors.count;
    _DoorEntry = [edgeDoors[_DoorEntry] intValue]; //the entry door
    _rooms[_StartRoom][_DoorEntry] = [NSNumber numberWithInt:-INT_ENTRYROOM]; //the entry door of the entry room
    _rooms[0][5-_DoorEntry] = [NSNumber numberWithInt:-_StartRoom]; //进入口前的虚拟房间
    // [_route addObject:[NSNumber numberWithInt:5-doorEntry]]; //入口不添加到路径
    //随机生成路径
    int currRoomNo = _StartRoom;
    int nextRoomNo = 0;
    int doorNext = 0;
    int lastDoor = _DoorEntry;
    while (true) {
        BOOL allLe0 = [_rooms[currRoomNo][0] intValue] <= 0  && [_rooms[currRoomNo][1] intValue] <= 0  && [_rooms[currRoomNo][2] intValue] <= 0  && [_rooms[currRoomNo][3] intValue] <= 0  && [_rooms[currRoomNo][4] intValue] <= 0  && [_rooms[currRoomNo][5] intValue] <= 0;
        if (allLe0 || [_routePassedRooms allKeys].count>_rooms.count*(2.0/_Level)) { //当通往其他房间的门都已开或者路径房间数大于阈值时，寻找出去的门；
            if ([_routePassedRooms allKeys].count>_rooms.count*(2.0/_Level)) { //优先找出去的门
                for (int i=0; i<6; i++) {
                    int exitRoomNo = [_rooms[currRoomNo][i] intValue];
                    if (exitRoomNo==0) {
                        nextRoomNo = exitRoomNo;
                        doorNext = i;
                        break;
                    }
                }
            }
            while ( nextRoomNo<0 ) {
                doorNext = [self getNextDoor:currRoomNo]; //arc4random() % 6;
                nextRoomNo = [_rooms[currRoomNo][doorNext] intValue];
            }
        } else {      //当前房间通往其他房间的门未都开，寻找通往其他房间的门而不是出去的门
            while ( nextRoomNo<=0 ) {
                doorNext = [self getNextDoor:currRoomNo]; //arc4random() % 6;
                nextRoomNo = [_rooms[currRoomNo][doorNext] intValue];
            }
        }
        if (nextRoomNo==0) {
            nextRoomNo = (int)_rooms.count-1;
        }
        if (nextRoomNo != (int)_rooms.count-1) {
            [_routePassedRooms setObject:[NSString stringWithFormat:@"%d",nextRoomNo] forKey:[NSString stringWithFormat:@"%d",nextRoomNo]];
        }
        //the door current room to next room
        [_rooms[currRoomNo] replaceObjectAtIndex:doorNext withObject:[NSNumber numberWithInt:-abs(nextRoomNo)]];
        //the door next room backto current room
        [_rooms[nextRoomNo] replaceObjectAtIndex:5-doorNext withObject:[NSNumber numberWithInt:-abs(currRoomNo)]];
        [_route addObject:[NSNumber numberWithInt:doorNext]]; //put next door index into the route
        currRoomNo = nextRoomNo;
        lastDoor = doorNext;
        doorNext = 0;
        if (nextRoomNo==_rooms.count-1) {
            break;
        }
        nextRoomNo = -1;
    }
    //添加星星
    int starCount = _Level-3;
    if (starCount>5) {
        starCount = 5;
    }
    while (_starRooms.count<starCount) {
        int starat = (arc4random() % [_routePassedRooms allKeys].count);
        id iroom = [[_routePassedRooms allKeys] objectAtIndex:starat];
        if (![_starRooms containsObject:iroom]) {
            [_starRooms addObject:iroom];
        }
    }
    //添加陷阱
    [self generateTraps];
}

-(void)generateTraps
{
    _traps = [NSMutableDictionary dictionary];
    _trapPassedRooms = [NSMutableDictionary dictionary];
    NSMutableDictionary *notPassed = [NSMutableDictionary dictionary];
    for (int i=1; i<_rooms.count-1; i++) {
        BOOL notpass = ![_routePassedRooms objectForKey:[NSString stringWithFormat:@"%d",i]];
        if (notpass) {
            [notPassed setObject:[NSString stringWithFormat:@"%d",i] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    while (notPassed.count>_RoomCount*(_Level-3)/2.0/11.0) {
        int rval = arc4random() % notPassed.count;
        int trapStartRoom = [[[notPassed allKeys] objectAtIndex:rval] intValue];
        int currRoomNo = trapStartRoom;
        NSMutableArray *trapRoute = [[NSMutableArray alloc] init];;
        while (TRUE) {
            int doorNext = [self getNextDoor:currRoomNo];
            [notPassed removeObjectForKey:[NSString stringWithFormat:@"%d",currRoomNo]];
            int nextRoomNo = [_rooms[currRoomNo][doorNext] intValue];
            while (nextRoomNo==0 || abs(nextRoomNo)==INT_ENTRYROOM || abs(nextRoomNo)==_rooms.count-1) {
                doorNext = [self getNextDoor:currRoomNo];
                nextRoomNo = [_rooms[currRoomNo][doorNext] intValue];
            }
            [trapRoute addObject:[NSString stringWithFormat:@"%d",doorNext]];
            [_trapPassedRooms setObject:[NSString stringWithFormat:@"%d",abs(nextRoomNo)] forKey:[NSString stringWithFormat:@"%d",abs(nextRoomNo)]];
            //
            [_rooms[abs(currRoomNo)] replaceObjectAtIndex:doorNext withObject:[NSNumber numberWithInt:-abs(nextRoomNo)]];
            [_rooms[abs(nextRoomNo)] replaceObjectAtIndex:5-doorNext withObject:[NSNumber numberWithInt:-abs(currRoomNo)]];
            //
            currRoomNo = nextRoomNo;
            if (nextRoomNo<0) {
                break;
            }
        }
        [_traps setObject:[trapRoute componentsJoinedByString:@""] forKey:[NSString stringWithFormat:@"%d",trapStartRoom]];
    }
    NSMutableDictionary *loopTraps = [[NSMutableDictionary alloc] initWithDictionary:_traps];
    //校验陷阱是否与正确路径连通
    for (id key in loopTraps) {
        int trapStartRoom = [key intValue];
        int currRoom = trapStartRoom;
        int nextRoom = 0;
        NSString *trapPath = [_traps objectForKey:key];
        NSMutableDictionary *passRooms = [NSMutableDictionary dictionary];
        [passRooms setObject:[NSString stringWithFormat:@"%d",currRoom] forKey:[NSString stringWithFormat:@"%d",currRoom]];
        int canGoRoom = 0, canGoDoor = 0;
        int insertPathPos = -1;
        for(int i = 0; i < [trapPath length]; i++) {
            for (int j=0; j<6; j++) {
                NSString *tmpRoom = [NSString stringWithFormat:@"%d",abs([_rooms[currRoom][j] intValue])];
                if ([[_routePassedRooms allKeys] containsObject:tmpRoom]) {
                    canGoRoom = currRoom;
                    canGoDoor = j;
                    insertPathPos = i;
                }
            }
            //
            int doorIndex = [[trapPath substringWithRange:NSMakeRange(i, 1)] intValue];
            nextRoom = [_rooms[currRoom][doorIndex] intValue];
            currRoom = abs(nextRoom);
            [passRooms setObject:[NSString stringWithFormat:@"%d",currRoom] forKey:[NSString stringWithFormat:@"%d",currRoom]];
        }
        //
        NSSet *set1 = [NSSet setWithArray:[passRooms allKeys]];
        NSSet *set2 = [NSSet setWithArray:[_routePassedRooms allKeys]];
        if (![set1 intersectsSet:set2]) {
            //陷阱路经与正确路径无交集
            if (canGoRoom>0 && insertPathPos>=0) {
                int l = trapPath.length;
                trapPath = [NSString stringWithFormat:@"%@%@%@%@",[trapPath substringWithRange:NSMakeRange(0, insertPathPos)], [NSString stringWithFormat:@"%d",canGoDoor], [NSString stringWithFormat:@"%d",5-canGoDoor], [trapPath substringWithRange:NSMakeRange(insertPathPos, l-insertPathPos)]];
                [_traps setObject:trapPath forKey:key];
                //
                nextRoom = [_rooms[abs(canGoRoom)][canGoDoor] intValue];
                [_rooms[abs(canGoRoom)] replaceObjectAtIndex:canGoDoor withObject:[NSNumber numberWithInt:-abs(nextRoom)]];
                [_rooms[abs(nextRoom)] replaceObjectAtIndex:5-canGoDoor withObject:[NSNumber numberWithInt:-abs(canGoRoom)]];
            }
        }
    }
}

-(NSString*) getMazeJsonData
{
    NSDictionary *mazeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:_Level], @"Level",
                              [NSNumber numberWithInt:_StartRoom], @"StartRoom",
                              [NSNumber numberWithInt:_DoorEntry], @"EntryDoor",
                              [_route componentsJoinedByString:@""], @"Path",
                              _traps, @"Traps",
                              _starRooms, @"Stars",
                              nil];
    return [HoneyComb getJsonString:mazeDict];
}

-(NSArray*) StarRooms
{
    NSArray *retval = [[NSArray alloc] initWithArray:_starRooms];
    return retval;
}

@end
