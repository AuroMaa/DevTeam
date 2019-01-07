//
//  HeartBeatRemoteConfig.m
//  DataLogger
//
//  Created by Madhu A on 7/19/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "HeartBeatRemoteConfig.h"

@implementation HeartBeatRemoteConfig

//-(void)setConfigValuesdict:(NSDictionary *)configValuesdict {
//    
//    if (self.configValuesdict != configValuesdict) {
//        self.configValuesdict = configValuesdict;
//    }
//}
//-(NSDictionary *)configValuesdict {
//    return self.configValuesdict;
//}

- (instancetype) init {
    self = [super init];
    
    if (!self) return nil;
    
    return self;
}


+ (HeartBeatRemoteConfig *) sharedConfigSettings
{
    static dispatch_once_t onceToken;
    static HeartBeatRemoteConfig *_instance;
    
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.settingsConfigValuesArray = [[NSMutableArray alloc]init];
        _instance.configValuesdict = [[NSMutableDictionary alloc]init];
    });
    return _instance;
}
@end
