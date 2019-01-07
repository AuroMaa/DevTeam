//
//  DLBarometerData.h
//  DataLogger
//
//  Created by Madhu A on 7/26/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLBarometerData : NSObject
@property (nonatomic, readonly) NSNumber *airPressure;
@property (nonatomic, readonly) NSNumber *relativeAltitude;
@property (nonatomic, readonly) NSNumber *timestamp;

- (void)addKeyValue:(NSString *)key withObject:(id)object;
- (id)getValueForKey:(NSString *)key;

extern NSString * const kairPressure;
extern NSString * const krelativeAltitude;
extern NSString * const ktimeStamp;

@end
