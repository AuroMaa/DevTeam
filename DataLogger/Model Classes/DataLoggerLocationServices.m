//
//  DataLoggerLocationServices.m
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "DataLoggerLocationServices.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#define kAccuracy       kCLLocationAccuracyBest
#define kDistance       10.0f


@interface DataLoggerLocationServices() <CLLocationManagerDelegate> {
    BOOL zerothSecondCall;

}
// Timer Operation
@property (nonatomic, strong) NSTimer *intervalTimer;
@property (nonatomic, strong) dispatch_source_t locationTimer;
@property (nonatomic, strong) dispatch_source_t barometerTimer;
@property (nonatomic) int savedInterval;
@property (nonatomic, assign) int timeCounter;
@property (nonatomic, strong) DLLocationData *lastLocation;



// Barometer operation
@property (nonatomic, strong) CMAltimeter *altimeter;
@property (nonatomic, strong) NSOperationQueue *threadManagerOperationQueue;
@property (nonatomic, strong) NSNumber *barometerPressure;
@property (nonatomic, strong) NSNumber *barometerAltitude;
@property (nonatomic, strong) NSNumber *barometerTimeStamp;
@property (nonatomic, strong) DLBarometerData *lastBarometerReadings;


// Operation Flags
@property (nonatomic, assign) BOOL setupDone;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL reportingLocs;
@property (nonatomic, assign) BOOL firstCall;
@property (nonatomic, assign) BOOL justOne;
@property (nonatomic, assign) BOOL continuousMode;
@property (nonatomic, assign) BOOL isBgService;

//@property (nonatomic, assign) BOOL isInBackground;

@end

@implementation DataLoggerLocationServices

+ (instancetype) sharedManager {
    
    static DataLoggerLocationServices *_sharedManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        _sharedManager = [[self alloc]init];
    });
    return _sharedManager;
    
}

- (instancetype) init
{
    if (self = [super init]) {
        self.savedInterval = 0;
        self.setupDone = NO;
        self.isStarted = NO;
        self.firstCall = NO;
        self.justOne = NO;
        self.continuousMode = NO;
//        self.lastLocation = nil;
        self.reportingLocs = NO;
        self.barometerPressure = @-1.0;
        self.isInBackground = NO;
        zerothSecondCall = NO;
    }
    return self;
}

- (void) dealloc {
    [self.manager stopUpdatingLocation];
    [self forceTimerOff];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)forceTimerOff {
    
}

-(void)invalidateTimers {
    if (self.locationTimer) {
        dispatch_source_cancel(self.locationTimer);
        self.locationTimer = nil;
    }
    if (self.barometerTimer) {
        dispatch_source_cancel(self.barometerTimer);
        self.barometerTimer = nil;
    }
    if (self.isAutomatedTestStarted) {
        if (self.altimeter) {
            [self.altimeter stopRelativeAltitudeUpdates];
        }
    }
    if (self.isAutomatedTestStarted) {
        if (self.manager) {
            [self stop];
        }
    }
}

-(void)invalidateAutoReportTimers {
    
}

#pragma mark - Application Cycle
- (void)becameActive
{
    self.isInBackground = NO;
    if (![self checkLocationStatus]) {
        [self forceTimerOff];
        self.reportingLocs = NO;
        if ([self.delegate respondsToSelector:@selector(locationServicesInvalid)]) {
            [self.delegate locationServicesInvalid];
        }
    } else {
        if (!self.reportingLocs) {
            if (self.continuousMode) {
                [self getLocationContinuous];
            } else {
                if (self.savedInterval != 0) {
//                    [self getLocationforTimeInterval:self.savedInterval];
                }
            }
            if ([self.delegate respondsToSelector:@selector(restartReporting)]) {
                [self.delegate restartReporting];
            }
            
        }
    }
}


- (void)becameBackground
{
    self.isInBackground = YES;
}

#pragma mark - CLLocationManager
-(void)startLocationForBackground
{
    _isBgService = YES;
    [self startMonitoringLocation];
    
}

- (void)startMonitoringLocation {
    if (self.manager)
        [self.manager stopMonitoringSignificantLocationChanges];
    
    self.manager = [[CLLocationManager alloc]init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.manager.activityType = CLActivityTypeOtherNavigation;
    [self.manager requestAlwaysAuthorization];
    [self.manager startMonitoringSignificantLocationChanges];
}

- (void)restartMonitoringLocation {
    [self.manager stopMonitoringSignificantLocationChanges];
    [self.manager requestAlwaysAuthorization];
    [self.manager startMonitoringSignificantLocationChanges];
}

#pragma mark - Public Methods

- (BOOL)setupLocationServices {
    NSLog(@"Setup Data Logger Location Services");
    self.manager = [[CLLocationManager alloc] init];
    self.manager.desiredAccuracy = kAccuracy;
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.pausesLocationUpdatesAutomatically = NO;

    self.manager.activityType = CLActivityTypeFitness;
    self.manager.delegate = self;
    
    
    if ([CLLocationManager instancesRespondToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        self.manager.allowsBackgroundLocationUpdates = YES;
    }
    
    if ([CLLocationManager instancesRespondToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.manager requestAlwaysAuthorization];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becameActive)
                                                 name:NSExtensionHostWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becameBackground)
                                                 name:NSExtensionHostDidEnterBackgroundNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(willTerminate)
//                                                 name:UIApplicationWillTerminateNotification
//                                               object:nil];
    
    
    self.setupDone = YES;
    return [self checkLocationStatus];
}

- (BOOL)checkLocationStatus {
    
    self.currentStatus = [CLLocationManager authorizationStatus];
    if ((self.currentStatus == kCLAuthorizationStatusAuthorizedAlways) || (self.currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse) || 
        (self.currentStatus == kCLAuthorizationStatusNotDetermined) ) {
        return YES;
    } else {
        return NO;
    }
}
-(void)startBarometerForBgService
{
    self.barometerPressure = [NSNumber numberWithFloat:-1.0];
    
    if([CMAltimeter isRelativeAltitudeAvailable])
    {
        self.altimeter = [[CMAltimeter alloc] init];
        self.threadManagerOperationQueue = [[NSOperationQueue alloc] init];
        if ([self.threadManagerOperationQueue respondsToSelector:@selector(setQualityOfService:)])
        {
            self.threadManagerOperationQueue.qualityOfService = NSQualityOfServiceBackground;
            self.barometerPressure = [NSNumber numberWithFloat:-1.0];
        }
        if([CMAltimeter isRelativeAltitudeAvailable])
        {
            [self.altimeter startRelativeAltitudeUpdatesToQueue:self.threadManagerOperationQueue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"ALtitude Error = %@", [error localizedDescription]);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.lastBarometerReadings = [self convertBaroData:altitudeData];
                        if ([self.delegate respondsToSelector:@selector(BaroUpdateForBgService:)]) {
                            [self.delegate BaroUpdateForBgService:self.lastBarometerReadings];
                        }
                    });
                }
            }];
        }
    }
    else
    {
        self.barometerPressure = [NSNumber numberWithFloat:-1.0];
    }
}

- (void) startBarometer {
    if (self.isStarted)
        return;
    NSLog(@"Start DataLogger Barometer Services");
    self.barometerPressure = [NSNumber numberWithFloat:-1.0];
    
    if([CMAltimeter isRelativeAltitudeAvailable]){
        self.altimeter = [[CMAltimeter alloc] init];
        self.threadManagerOperationQueue = [[NSOperationQueue alloc] init];
        if ([self.threadManagerOperationQueue respondsToSelector:@selector(setQualityOfService:)]) {
            self.threadManagerOperationQueue.qualityOfService = NSQualityOfServiceBackground;
            self.barometerPressure = [NSNumber numberWithFloat:-1.0];
        }
        if([CMAltimeter isRelativeAltitudeAvailable]){
            [self.altimeter startRelativeAltitudeUpdatesToQueue:self.threadManagerOperationQueue withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
                if (error) {
                    NSLog(@"ALtitude Error = %@", [error localizedDescription]);
                } else {
//                    self.barometerPressure = [NSNumber numberWithFloat:altitudeData.pressure.floatValue];
//                    self.barometerAltitude = [NSNumber numberWithFloat:altitudeData.relativeAltitude.floatValue];
//                    self.barometerTimeStamp = [NSNumber numberWithFloat:altitudeData.timestamp];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.lastBarometerReadings = [self convertBaroData:altitudeData];

                        NSMutableDictionary *dictEstl = [[NSMutableDictionary alloc]init];
                        [dictEstl setValue:self.lastBarometerReadings forKey:@"Baro"];
                        NSNotification *myNotification = [NSNotification notificationWithName:@"Barometer"
                                                                                       object:self //object is usually the object posting the notification
                                                                                     userInfo:dictEstl]; //userInfo is an optional dictionary
                        
                        //Post it to the default notification center
                        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
                    });

                }
            }];
        }
    } else {
        self.barometerPressure = [NSNumber numberWithFloat:-1.0];
    }
    // Legacy fix - if the app calls start() without setup
    if (!self.setupDone) {
        [self setupLocationServices];
    }
    self.isStarted = YES;
    [self.manager startUpdatingLocation];
}

- (void) stop {
    if (!self.isStarted)
        return;
    NSLog(@"Stop LocationServices");
    self.isStarted = NO;
    self.continuousMode = NO;
    if([CMAltimeter isRelativeAltitudeAvailable]){
        [self.altimeter stopRelativeAltitudeUpdates];
        self.altimeter = nil;
        [self.threadManagerOperationQueue cancelAllOperations];
        self.threadManagerOperationQueue = nil;
    }
    self.reportingLocs = NO;
    [self.manager stopUpdatingLocation];
    self.manager = nil;
}

- (void)singleShot {
    NSLog(@"SingleShot");
    if (!self.isStarted) {
        NSLog(@"Location not started");
        return;
    }
    if (![self checkLocationStatus]) {
        return;
    }
    // Apple does not allow a oneShot while currently reporting
    [self.manager stopUpdatingLocation];
    self.justOne = YES;
    [self.manager requestLocation];
}

- (void)getLocationContinuous {
    NSLog(@"getLocationContinuous");
    if (!self.isStarted) {
        NSLog(@"Location not started");
        return;
    }
    if (![self checkLocationStatus]) {
        return;
    }
    self.savedInterval = 0;
    self.continuousMode = YES;
    if (self.reportingLocs) {
        [self forceTimerOff];
        [self.manager stopUpdatingLocation];
    } else {
        self.reportingLocs = YES;
    }
    [self.manager startUpdatingLocation];
}

#pragma mark - Initializing Location & Baro Timers for AutomatedTests

- (void)getLocationforTimeInterval:(int)interval withInitialDelayOfInterval:(int)delay {
    NSLog(@"getLocation for every:%i seconds", interval);
   
    if (![self checkLocationStatus]) {
        [self setupLocationServices];
    }
    self.savedInterval = interval;
    if (interval == 0) {
        [self forceTimerOff];
        self.continuousMode = NO;
        return;
    }
    if (self.reportingLocs) {
        [self forceTimerOff];
        self.continuousMode = NO;
        [self.manager stopUpdatingLocation];
    } else {
        self.reportingLocs = YES;
    }
    self.firstCall = YES;
//    [self.manager requestLocation];
    [self.manager startUpdatingLocation];
    
    float IntervalSecs = interval / 1000.0;
    NSTimeInterval rqInterval = IntervalSecs;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self triggerLocationTimerWithInterval:rqInterval];
    });

}
- (void)getBarometerReadings_forInterval:(int)interval withInitialDelayOfInterval:(int)delay {
    
    float IntervalSecs = interval / 1000.0;
    NSTimeInterval rqInterval = IntervalSecs;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //Do whatever after 1 second
        [self triggerBaroTimerWithInterval:rqInterval];
        
    });
}

-(void)triggerLocationTimerWithInterval:(int )interval {
    //----Collecting Data for 0th second----////
    if ([self.delegate respondsToSelector:@selector(locationDataReceived:)]) {
        [self.delegate locationDataReceived:self.lastLocation];
    }
    //-----Creating Timer to collect location data for the interval---////
    self.locationTimer = CreateDispatchLocationTimer(interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Repeating task
        [self locationTimerFired];
    });

}

-(void)triggerBaroTimerWithInterval:(NSTimeInterval )interval {
    
    //----Collecting Data for 0th second----//
    if ([self.delegate respondsToSelector:@selector(barometerDataReceived:)]) {
        [self.delegate barometerDataReceived:self.lastBarometerReadings];
    }
    
    //-----Creating Timer to collect location data for the interval----//
    self.barometerTimer = CreateDispatchBarometerTimer(interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Repeating task
        [self barometerTimerFired];
    });

}
#pragma mark - Initializing Location & Baro Timers for AutoReport Tests

-(void)sendBaroDatafor_AutoReportService {
    
//    self.barometerTimer = CreateDispatchBarometerTimer(1 * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Repeating task
        [self barometerTimerFired];
//    });
}

-(void)sendLocationDatafor_AutoReportService {
//    self.locationTimer = CreateDispatchLocationTimer(1 * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Repeating task
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];

        NSLog(@"time loc   : %@",intervalString);
        [self locationTimerFired];
//    });
    
}

#pragma  mark - Location and Baro Data Collection timer Delegates
- (void)barometerTimerFired {
    
    if ([self.delegate respondsToSelector:@selector(barometerDataReceived:)]) {
        [self.delegate barometerDataReceived:self.lastBarometerReadings];
    }
}

- (void)locationTimerFired {
    if ([self.delegate respondsToSelector:@selector(locationDataReceived:)]) {
        [self.delegate locationDataReceived:self.lastLocation];
    }
}


dispatch_source_t CreateDispatchLocationTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        // Setup params for creation of a recurring timer
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
        dispatch_source_set_timer(timer,startTime, interval,0);
        
        // Attach the block you want to run on the timer fire
        dispatch_source_set_event_handler(timer, block);
        
        // Start the timer
        dispatch_resume(timer);
    }
    return timer;
}
dispatch_source_t CreateDispatchBarometerTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = nil;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        // Setup params for creation of a recurring timer
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
        dispatch_source_set_timer(timer,startTime, interval,0);
        
        // Attach the block you want to run on the timer fire
        dispatch_source_set_event_handler(timer, block);
        
        // Start the timer
        dispatch_resume(timer);
    }
    return timer;
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count == 0)
        return;
//    CLLocation* location = [locations lastObject];
//    NSLog(@"latitude %+.6f, longitude %+.6f\n",
//          location.coordinate.latitude,
//          location.coordinate.longitude);
    
    self.lastLocation = [self convertLoc:[locations lastObject]];
    if (self.isBgService)
    {
        self.isBgService = NO;
        if ([self.delegate respondsToSelector:@selector(locationUpdateForBgService:)]) {
            [self.delegate locationUpdateForBgService:self.lastLocation];
        }
        return;
    }

    if (self.justOne) {
        if ([self.delegate respondsToSelector:@selector(locationDataReceived:)]) {
            [self.delegate locationDataReceived:self.lastLocation];
        }
        self.justOne = NO;
        if (self.reportingLocs) {
            [manager startUpdatingLocation];
        }
        return;
    }
    if (self.firstCall) {
        self.firstCall = NO;
        [manager startUpdatingLocation];
    }
//    if (self.isAutomatedTestStarted) {
//        if ([self.delegate respondsToSelector:@selector(locationDataReceived:)]) {
//            [self.delegate locationDataReceived:self.lastLocation];
////        }
//    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    self.lastLocation = nil;
    if (self.isInBackground) {
        if ([self.delegate respondsToSelector:@selector(locationDataReceived:)]) {
            [self.delegate locationDataReceived:nil];
        }
        return;
    }
    NSLog(@"locManager failed with error: %@", [error localizedDescription]);
    [self forceTimerOff];
    self.reportingLocs = NO;
}

#pragma mark - Helper methods

- (DLLocationData *)convertLoc:(CLLocation *)result
{
    DLLocationData *rtn = [[DLLocationData alloc] init];
    
    // show current time
    // If standing still, might retrieve an older fix
    [rtn addKeyValue:kLocationTime withObject:[NSDate date]];
    NSNumber *temp = [NSNumber numberWithDouble:result.coordinate.latitude];
    [rtn addKeyValue:kLatitude withObject:temp];
    temp = [NSNumber numberWithDouble:result.coordinate.longitude];
    [rtn addKeyValue:kLongitude withObject:temp];
    temp = [NSNumber numberWithDouble:result.horizontalAccuracy];
    [rtn addKeyValue:kHorizonalAccuracy withObject:temp];
    temp = [NSNumber numberWithDouble:result.altitude];
    [rtn addKeyValue:kHeight withObject:temp];
    temp = [NSNumber numberWithDouble:result.verticalAccuracy];
    [rtn addKeyValue:kVerticalAccuracy withObject:temp];
    if ([result respondsToSelector:@selector(floor)]) {
        temp = [NSNumber numberWithInteger:result.floor.level];
        [rtn addKeyValue:kFloor withObject:temp];
    }
    // ToDo - Apple does not return floor accuracy
    [rtn addKeyValue:kFloorAccuracy withObject:@0];
    
    [rtn addKeyValue:kBarometer withObject:self.barometerPressure];
    return rtn;
}

-(DLBarometerData *)convertBaroData:(CMAltitudeData *)result {
    
    DLBarometerData *rtn = [[DLBarometerData alloc]init];
    NSNumber *temp = result.relativeAltitude;
    [rtn addKeyValue:krelativeAltitude withObject:temp];
    temp = result.pressure;
    [rtn addKeyValue:kairPressure withObject:temp];
    NSNumber *timeStamp = [NSNumber numberWithDouble:result.timestamp];
    [rtn addKeyValue:ktimeStamp withObject:timeStamp];

    return rtn;
}

@end
