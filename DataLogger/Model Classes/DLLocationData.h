//
//  DLLocationData.h
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

//Suggested keys for ios CLLocation code
#define gps_Keys @[ @"kTime", @"klat", @"klon", @"kHor_acc"];


#import <Foundation/Foundation.h>

@interface DLLocationData : NSObject

@property (nonatomic, readonly) NSNumber *latitude;
@property (nonatomic, readonly) NSNumber *longitude;
@property (nonatomic, readonly) NSNumber *horizontalAccuracy;
@property (nonatomic, readonly) NSNumber *height;
@property (nonatomic, readonly) NSNumber *verticalAccuracy;
@property (nonatomic, readonly) NSNumber *barometer;
@property (nonatomic, readonly) NSNumber *floor;
@property (nonatomic, readonly) NSNumber *floorAccuracy;
@property (nonatomic, readonly) NSDate *timestamp;



- (void)addKeyValue:(NSString *)key withObject:(id)object;
- (id)getValueForKey:(NSString *)key;

extern NSString * const kLocationTime;
extern NSString * const kLatitude;
extern NSString * const kLongitude;
extern NSString * const kHorizonalAccuracy;
extern NSString * const kHeight;
extern NSString * const kBarometer;
extern NSString * const kVerticalAccuracy;
extern NSString * const kFloor;
extern NSString * const kFloorAccuracy;

@end
