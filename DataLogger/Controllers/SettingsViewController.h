//
//  SettingsViewController.h
//  DataLogger
//
//  Created by Madhu A on 7/19/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol settingsConfigChange;

@interface SettingsViewController : UIViewController
@property (nonatomic, strong)NSMutableArray *settingConfigArray;
@property (nonatomic, strong) id <settingsConfigChange>testingConfigDelegate;
@end

@protocol settingsConfigChange <NSObject>

-(void)settingsRemoteConfigValuesChangedfor:(NSString *)method withConfigValue:(NSString *)configValue;
@end
