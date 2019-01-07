//
//  DataLoggerLocationServices.h
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLocationData.h"
#import "DLBarometerData.h"
#import <CoreLocation/CoreLocation.h>

@protocol DataLoggerLocationDelegate <NSObject>
@optional
-(void)locationDataReceived:(DLLocationData *)location;
-(void)barometerDataReceived:(DLBarometerData *)barometerReadings;
-(void)barometerDataReceived:(NSNumber *)barometerAirPressure relativedata:(NSNumber *)altitude timeStamp:(NSNumber *)time;
- (void)locationServicesInvalid;
- (void)restartReporting;
-(void)locationUpdateForBgService:(DLLocationData*)data;
-(void)BaroUpdateForBgService:(DLBarometerData*)data;

@end


@interface DataLoggerLocationServices : NSObject

@property (nonatomic, weak) id delegate;
// Location Manager Operation
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, assign) BOOL isInBackground;
@property (nonatomic, assign) BOOL isAutomatedTestStarted;
@property (nonatomic, assign) BOOL isAutoReportTestStarted;
@property (strong,nonatomic) NSDictionary *uploadLocationdict;
@property (nonatomic, assign) CLAuthorizationStatus currentStatus;

////////////////////////////////
// singleton access
////////////////////////////////
- (instancetype)init ;

+ (instancetype) sharedManager;

////////////////////////////////
// setup
////////////////////////////////
/*
 * Ensures the user has set Location Services
 * so that the app can use it.
 *
 * returns the status
 */
- (BOOL)setupLocationServices;
- (void)startLocationForBackground;
- (void)startBarometerForBgService;

////////////////////////////////
// checkLocationStatus
////////////////////////////////
/*
 * checkLocationStatus
 *
 * a non-blocking call to check if
 * there are LocationServices AND
 * our app has the permission set to always
 */
- (BOOL)checkLocationStatus;


////////////////////////////////
// start stop
////////////////////////////////
/*
 * start
 *
 * startup and do any initialization
 *
 * called once during app initialization
 * (create keep_alive and background code)
 */
- (void) startBarometer;

/*
 * stop
 *
 * stop and cleanup
 *
 * called once at app end
 * (cleanup and quiesce)
 */
- (void) stop;


////////////////////////////////
// Gather location data
////////////////////////////////
//
// both will check for the existance of a delegate
// and report the location thru the Protocol callback when available
//
////////////////////////////////


/* singleShot
 *
 * get one location immediately
 * The data is returned by calling the delegate method (locationDataReceived)
 *
 */
- (void)singleShot;


/*
 * getLocation
 *
 * Returns a location based on the interval
 * The data is returned by calling the delegate method (locationDataReceived)
 *
 * if (interval == 0)
 *     stop gathering location data
 * else if (interval != 0)
 *        if (running) stop
 *      start gathering location data at interval time
 */
- (void)getLocationforTimeInterval:(int)interval withInitialDelayOfInterval:(int)delay;

/*
 * getLocationContinuous
 *
 * Returns location data as it is received
 * The data is returned by calling the delegate method (locationDataReceived)
 *
 * use getLocations(0) to stop it
 *
 */
- (void)getLocationContinuous;

/*
 * getBarometerReadings
 *
 * Returns Baromatere Based Readings on the interval
 *The data is returned by calling the delegate method (BarometerReadingsReceived)
 *
 */
- (void)getBarometerReadings_forInterval:(int)interval withInitialDelayOfInterval:(int)delay;
-(void)sendBaroDatafor_AutoReportService;
-(void)sendLocationDatafor_AutoReportService;
-(void)invalidateTimers;
- (void)startMonitoringLocation;
- (void)restartMonitoringLocation;
@end
