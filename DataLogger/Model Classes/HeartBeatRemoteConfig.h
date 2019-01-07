//
//  HeartBeatRemoteConfig.h
//  DataLogger
//
//  Created by Madhu A on 7/19/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeartBeatRemoteConfig : NSObject
@property (nonatomic,strong) NSNumber *testIntervalInSeconds;
@property (nonatomic,strong) NSNumber *autoReportIntervalInSecs;
@property (nonatomic,strong) NSString *testLocationName;
@property (nonatomic,strong) NSNumber *testNumberOfTests;
@property (nonatomic,strong) NSString *testSubscriberId;
@property (nonatomic,strong) NSString *testIMEINumber;
@property (nonatomic,strong) NSNumber *barometerUpdateRate;
@property (nonatomic,strong) NSNumber *locationUpdateRate;
@property (nonatomic,strong) NSNumber *Vo_update_rate_in_ms;
@property (nonatomic,strong) NSNumber *initialDelay;
@property (nonatomic,strong) NSMutableDictionary *configValuesdict;
@property (nonatomic,strong) NSMutableArray *settingsConfigValuesArray;
+ (HeartBeatRemoteConfig *) sharedConfigSettings;
@end
