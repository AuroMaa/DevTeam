//
//  DLLocationData.m
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "DLLocationData.h"

NSString *const kLocationTime = @"kLocationTime";
NSString *const kLatitude = @"kLatitude";
NSString *const kLongitude = @"kLongitude";
NSString *const kHorizonalAccuracy = @"kHorizonalAccuracy";
NSString *const kHeight = @"kHeight";
NSString *const kBarometer = @"kBarometer";
NSString *const kVerticalAccuracy = @"kVerticalAccuracy";
NSString * const kFloor = @"kFloor";
NSString * const kFloorAccuracy = @"kFloorAccuracy";

@interface DLLocationData ()

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation DLLocationData

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addKeyValue:(NSString *)key withObject:(id)object
{
    [self.data setObject:object forKey:key];
}

- (id)getValueForKey:(NSString *)key
{
    return [self.data valueForKey:key];
}

- (NSNumber*) latitude {
    return [self getValueForKey:kLatitude];
}

- (NSNumber*) longitude {
    return [self getValueForKey:kLongitude];
}

- (NSNumber*)  height{
    return [self getValueForKey:kHeight];
}

- (NSNumber*)  barometer{
    return [self getValueForKey:kBarometer];
}


- (NSNumber*) horizontalAccuracy {
    return [self getValueForKey:kHorizonalAccuracy];
}

- (NSNumber*) verticalAccuracy {
    return [self getValueForKey:kVerticalAccuracy];
}

- (NSNumber*) floor {
    return [self getValueForKey:kFloor];
}

- (NSNumber*) floorAccuracy {
    return [self getValueForKey:kFloorAccuracy];
}

- (NSDate*) timestamp {
    return [self getValueForKey:kLocationTime];
}

@end
