//
//  SensorViewController.h
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/27/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorViewController : UIViewController



@property (weak, nonatomic) IBOutlet UILabel *lblArKitXPos;
@property (weak, nonatomic) IBOutlet UILabel *lblArKitYPos;
@property (weak, nonatomic) IBOutlet UILabel *lblArKitZPos;

@property (weak, nonatomic) IBOutlet UILabel *lblPressure;
@property (weak, nonatomic) IBOutlet UILabel *lblAccX;
@property (weak, nonatomic) IBOutlet UILabel *lblAccY;
@property (weak, nonatomic) IBOutlet UILabel *lblAccZ;


@property (weak, nonatomic) IBOutlet UILabel *lblMgnX;
@property (weak, nonatomic) IBOutlet UILabel *lblMgnY;
@property (weak, nonatomic) IBOutlet UILabel *lblMgnZ;


@property (weak, nonatomic) IBOutlet UILabel *lblGyrX;
@property (weak, nonatomic) IBOutlet UILabel *lblGyrY;
@property (weak, nonatomic) IBOutlet UILabel *lblGyrZ;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblIsBatteryCharging;
@property (weak, nonatomic) IBOutlet UILabel *lblIntensity;
@property (weak, nonatomic) IBOutlet UILabel *lblProximity;

@end

NS_ASSUME_NONNULL_END
