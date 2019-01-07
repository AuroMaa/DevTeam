//
//  DLUploadTestResultsData.h
//  DataLogger
//
//  Created by Madhu A on 7/30/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"


@interface DLUploadTestResultsData : JSONModel
@property (nonatomic, strong) NSDictionary *device;
@property (nonatomic, strong) NSArray *estLlh;
@property (nonatomic, strong) NSDictionary *groundtruth;
@property (nonatomic, strong) NSNumber *horzUnc;
@property (nonatomic, strong) NSNumber *vertUnc;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSNumber *request_start_time;
@property (nonatomic, strong) NSNumber *request_received_time;
@property (nonatomic, strong) NSNumber *time_to_fix;
@property (nonatomic, strong) NSNumber *request_respond_time;



@end
