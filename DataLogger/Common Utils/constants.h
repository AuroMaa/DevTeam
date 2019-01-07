//
//  constants.h
//  DataLogger
//
//  Created by Madhu A on 7/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#ifndef constants_h
#define constants_h

#define hearBeatAPIURL @"http://demo-d1.polariswireless.com/HeartBeatAndRemoteConfig.php?"
#define locationRequet @"http://demo-d1.polariswireless.com/locationRequest.php?"
#define autoReportRequest @"http://demo-d1.polariswireless.com/autoReport.php?"

// Settings Page Table Headers
#define SettingsTableHeader1 @"Automated Location Test Settings"
#define DDataCollectionHeader @"Different Data Collection Interval for A.L.Test"
#define CompassPedometerHeader @"Compass Pedometer"
#define AutoReport Service @"AutoReport Service"
#define Battery Optimization @"BatteryOptimization"

//Settings Page Input Headers
#define Configid @"Config id"
#define TestingServerConnec @"HeartBeat RemoteTesting Server Connection URL"
#define TestingServerConnec1 @"Foreground Testing Server Connection URL"
#define TestingServerConnec2 @"Background Testing Server Connection URL"
#define SampleDemoURL @"http://demo-d1.polariswireless.com/HeartBeatAndRemoteConfig.php?"
#define AutomationServiceDelay @"Automation Service Initial Delay in seconds"
#define DelayInms @"Delay in ms"
#define EnableBarometer @"Enable Barometer"
#define BaroUpdateRate @"Baro Update Rate in ms"
#define EnableLocation @"Enable Location"
#define LocationUpdateRate @"Location Update rate in ms"
#define ResultCount @"Number of results to be displayed"
#define VersionNumber @"Version Number"
#define BuildNumber @"Build Number"
#define EnableARKit @"Enable ARKit"

#endif /* constants_h */
