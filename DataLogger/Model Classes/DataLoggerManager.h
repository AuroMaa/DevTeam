//
//  DataLoggerManager.h
//  DataLogger
//
//  Created by Madhu A on 8/1/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoggerManager : NSObject
@property (nonatomic,strong)NSMutableArray *dataArray;

#pragma mark -
#pragma mark Class Methods
+ (DataLoggerManager *)sharedLogger;

@end
