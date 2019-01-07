 //
//  SensorViewController.m
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/27/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "SensorViewController.h"
#import "DLBarometerData.h"
#import <CoreMotion/CoreMotion.h>

@interface SensorViewController ()<UIAccelerometerDelegate>
{
    BOOL isUpdate;
    CMMotionManager *motionManager;
    
}
@end

@implementation SensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    motionManager = [[CMMotionManager alloc]init];
    motionManager.accelerometerUpdateInterval  = 1;
    motionManager.gyroUpdateInterval  = 1;
    motionManager.magnetometerUpdateInterval  = 1;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadBarometer:)
     name:@"Barometer"
     object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isUpdate = true;
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    if (motionManager.accelerometerAvailable) {
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (error == nil)
            {
                if (self->isUpdate)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_lblAccX.text = [NSString stringWithFormat:@"%f",accelerometerData.acceleration.x];
                        self->_lblAccY.text = [NSString stringWithFormat:@"%f",accelerometerData.acceleration.y];
                        self->_lblAccZ.text = [NSString stringWithFormat:@"%f",accelerometerData.acceleration.z];
                        
                    });
                }
                
            }
        }];
    }
    
    if ([motionManager isGyroAvailable])
    {
        [motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (error == nil)
            {
                if (self->isUpdate)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_lblGyrX.text = [NSString stringWithFormat:@"%f",gyroData.rotationRate.x];
                        self->_lblGyrY.text = [NSString stringWithFormat:@"%f",gyroData.rotationRate.y];
                        self->_lblGyrZ.text = [NSString stringWithFormat:@"%f",gyroData.rotationRate.z];
                        
                    });
                }
            }
        }];
    }
    if ([motionManager isMagnetometerAvailable])
    {
        
        [motionManager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            if (error == nil)
            {
                if (self->isUpdate)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_lblMgnX.text = [NSString stringWithFormat:@"%f",magnetometerData.magneticField.x];
                        self->_lblMgnY.text = [NSString stringWithFormat:@"%f",magnetometerData.magneticField.y];
                        self->_lblMgnZ.text = [NSString stringWithFormat:@"%f",magnetometerData.magneticField.z];
                        
                    });
                }
            }
        }];
    }
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    int batteryLevel = 0.0;
    float batteryCharge = [device batteryLevel];
    if (batteryCharge > 0.0f) {
        batteryLevel = batteryCharge * 100;
        _lblBatteryLevel.text = [NSString stringWithFormat:@"%d",batteryLevel];
    } else {
        _lblBatteryLevel.text = @"N/A";
    }
    
    if ([device batteryState] == UIDeviceBatteryStateCharging)
    {
        _lblIsBatteryCharging.text = @"YES";
    }
    else
    {
        _lblIsBatteryCharging.text = @"NO";
        
    }
    _lblIntensity.text = [NSString stringWithFormat:@"%.2f",[[UIScreen mainScreen] brightness]];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        self->_lblProximity.text = [NSString stringWithFormat:@"Close"];
    }
    else
    {
        self->_lblProximity.text = [NSString stringWithFormat:@"Far"];
    }

    
    // Set up an observer for proximity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    
}
- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if (isUpdate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIDevice currentDevice] proximityState] == YES)
            {
                self->_lblProximity.text = [NSString stringWithFormat:@"Close"];
            }
            else
            {
                self->_lblProximity.text = [NSString stringWithFormat:@"Far"];
            }
        });
        
    }
}

-(void)reloadBarometer:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        DLBarometerData *baro = [dict valueForKey:@"Baro"];
        NSLog(@"Pressure is %f",[baro.airPressure doubleValue]);
        if (self->isUpdate)
        {
            self->_lblPressure.text = [NSString stringWithFormat:@"%f",[baro.airPressure doubleValue]];
        }
    });
}
- (IBAction)pauseBtnClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    isUpdate = !sender.isSelected;
}

@end

