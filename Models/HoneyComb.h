//
//  HoneyComb.h
//  HoneyCombIOS
//  maze
//  Created by DongYigung on 15/2/27.
//  Copyright (c) 2015年 ADA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Consts.h"

@interface HoneyComb : NSObject {
    int _RoomCount;
    NSMutableArray *_rooms; //NSArray *room
    NSMutableArray *_edgeRoomNos; //NSInteger
    NSMutableArray *_route; //NSInteger[0..5]
    NSMutableArray *_starRooms;
    NSMutableDictionary *_routePassedRooms;
    NSMutableDictionary *_trapPassedRooms;
    NSMutableDictionary *_traps;
}

@property (nonatomic, assign) int Level;
@property (nonatomic, assign) int StartRoom;
@property (nonatomic, assign) int DoorEntry;

+(id)getObjectFromJson:(NSString*)json;
+(NSString*)getJsonString:(id)obj;

- (instancetype)initWithJsonData:(NSString*)jsonData;

-(void) setLevel:(int)newLevel;
-(int) RoomCount;
-(NSMutableArray*) Room:(int)roomNumber;
-(void) generateRoute;
-(NSString*) getMazeJsonData;
-(NSArray*) StarRooms;

@end
