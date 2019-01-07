//
//  DataLoggerManager.m
//  DataLogger
//
//  Created by Madhu A on 8/1/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "DataLoggerManager.h"

@implementation DataLoggerManager

#pragma mark -
#pragma mark Class Methods
+ (DataLoggerManager *)sharedLogger {
    static DataLoggerManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.dataArray = [[NSMutableArray alloc]init];
    });
    return _sharedInstance;
}

@end
//
