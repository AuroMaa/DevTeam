//
//  ViewController.h
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "FDKeychain.h"
#import "SettingsViewController.h"

@import UserNotifications;


@interface ViewController : UIViewController<settingsConfigChange>
@property (weak, nonatomic) IBOutlet UILabel *lblCurrent;

@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblReceived;


- (void)insertNewObjectForFetchWithCompletionHandler:(void (^)(void))completionHandler;

@end

