//
//  DLBarometerData.m
//  DataLogger
//
//  Created by Madhu A on 7/26/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "DLBarometerData.h"

NSString *const krelativeAltitude = @"krelativeAltitude";
NSString *const kairPressure = @"kpressure";
NSString *const ktimeStamp = @"ktimeStamp";

@interface DLBarometerData ()

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation DLBarometerData

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
//    NSLog(@"Baro Values:%@",self.data);
    return [self.data valueForKey:key];
}

- (NSNumber*) relativeAltitude {
    return [self getValueForKey:krelativeAltitude];
}

- (NSNumber*) airPressure {
    return [self getValueForKey:kairPressure];
}

- (NSNumber*) timestamp{
    return [self getValueForKey:ktimeStamp];
}

@end
