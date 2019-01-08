//
//  AppDelegate.m
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <CoreLocation/CoreLocation.h>
#import "DataLoggerLocationServices.h"
#import "constants.h"
#import "ViewController.h"
@import UserNotifications;


@interface AppDelegate ()<CLLocationManagerDelegate,DataLoggerLocationDelegate,UNUserNotificationCenterDelegate,ARSessionDelegate> {
    CLLocationManager *locationMgr;
    DataLoggerLocationServices *locationServices;
    
}
@property (strong,nonatomic) NSMutableArray * locDataArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"app launching");
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.locDataArray = [[NSMutableArray alloc]init];
    self.arrResponse = [[NSMutableArray alloc]init];
    locationServices = [DataLoggerLocationServices sharedManager];
    self.isFirstTime = @"true";
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"ResultCount"];
    if ([str  isEqual: @""]|| str == nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"20" forKey:@"ResultCount"];
    }
    NSString *strArRate = [[NSUserDefaults standardUserDefaults] valueForKey:@"ARRate"];
    if ([strArRate  isEqual: @""] || strArRate == nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1000" forKey:@"ARRate"];
    }
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error) {
                                  NSLog(@"request authorization succeeded!");
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
                                     /* PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
                                      pushRegistry.delegate = self;
                                      pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];*/

                                  });
//                                  [self showAlert];
                              }
                              else {
                                  [self showAlert:@"Push Notification Request Authorization Failed"];
                              }
                          }];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"UIApplicationLaunchOptionsLocationKey");
        locationServices = [DataLoggerLocationServices sharedManager];
        locationServices.delegate = self;
        [locationServices startMonitoringLocation];
    }
    else if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil) {
            NSLog(@"userInfo->%@", [userInfo objectForKey:@"aps"]);
        }

    } else {
        
    }
    [Fabric with:@[[Crashlytics class]]];
    return YES;
}
-(void)initialiseAR
{
    if (@available(iOS 11.3, *)) {
        _sceneView = [[ARSCNView alloc]initWithFrame:CGRectMake(260, 200, 100, 120)];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
        if ([intervalString length] > 0)
        {
            _arInitailiseTime = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:round(timeStamp * 1000)]];
        }        
        
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc]init];
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        [[_sceneView session] runWithConfiguration:configuration];
        [[_sceneView session] setDelegate:self];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [_sceneView setShowsStatistics:YES];
        [self.window addSubview:_sceneView];
        
    } else {
        // Fallback on earlier versions
    }
    
}
-(void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
API_AVAILABLE(ios(11.0)){
    if (_isstartTest && [[NSUserDefaults standardUserDefaults] boolForKey:@"EnableARKit"])
    {
        SCNVector3 cameraPosition = SCNVector3Make(frame.camera.transform.columns[3].x, frame.camera.transform.columns[3].y, frame.camera.transform.columns[3].z);
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
        
        _dictCameraPosition = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:cameraPosition.x],@"x",[NSNumber numberWithFloat:cameraPosition.y],@"y",[NSNumber numberWithFloat:cameraPosition.z],@"z",[intervalString length] > 0 ? [NSNumber numberWithDouble:round(timeStamp * 1000)] : [NSNumber numberWithDouble:0.0],@"current_time",[NSNumber numberWithInteger:[_arInitailiseTime integerValue]],@"start_time",nil];
        _sceneView.hidden = NO;
        
    }
    else
    {
        _sceneView.hidden = YES;
        
    }
    
}

-(void)session:(ARSession *)session didFailWithError:(NSError *)error
API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.3, *)) {
        if (![error isKindOfClass:[ARErrorDomain class]])
        {
            return;
        }
        NSError *errorWithInfo = (NSError*)error;
        NSArray *messages = [NSArray arrayWithObjects:errorWithInfo.localizedDescription,errorWithInfo.localizedFailureReason,errorWithInfo.localizedRecoverySuggestion, nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@\n%@\n%@",messages[0],messages[1],messages[2]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        
    }
}
-(void)sessionInterruptionEnded:(ARSession *)session
API_AVAILABLE(ios(11.0)){
    [self resetTracking];
}
-(void)resetTracking
{
    if (@available(iOS 11.0, *)) {
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc]init];
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        [[_sceneView session] runWithConfiguration:configuration];
    } else {
        // Fallback on earlier versions
    }
    
}


- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"******Push Notification token is NULL************");
        [self showAlert:@"Push Notification Token Error"];
        return;
    }
    
    NSLog(@"PushCredentials: %@", credentials.token);
    _deviceToken = [self stringWithDeviceToken:credentials.token];
    NSLog(@"PushCredentials - Device Token : %@", _deviceToken);
    NSString * deviceTokenString = [[[[_deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"The generated device token string is : %@",deviceTokenString);

}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhx", data[i]];
    }
    
    return [token copy];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion {
    NSLog(@"didReceiveIncomingPushWithPayload");
    [[DataLoggerLocationServices sharedManager]startBarometer];
    [[DataLoggerLocationServices sharedManager]startMonitoringLocation];
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
    id topViewController = navigationController.topViewController;
    if ([topViewController isKindOfClass:[ViewController class]]) {
        [(ViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:completion];
    } else {
        NSLog(@"Not the right class %@.", [topViewController class]);
    }


}


//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    NSLog(@"didReceiveIncomingPushWithPayload");
    [[DataLoggerLocationServices sharedManager]startBarometer];
    [[DataLoggerLocationServices sharedManager]startMonitoringLocation];
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
//    id topViewController = navigationController.topViewController;
    if ([navigationController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tvc = (UITabBarController*)navigationController;
        ViewController *vc = (ViewController*)[(UINavigationController*)[tvc viewControllers][0] viewControllers][0];
        [vc insertNewObjectForFetchWithCompletionHandler:nil];
    } else {
        NSLog(@"Not the right class %@.", [navigationController class]);
    }

}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
}
//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if(applicationState == UIApplicationStateInactive)
    {
        /*
         # App is transitioning from background to foreground (user taps notification), do what you need when user taps here!
         // opened from a push notification when the app was on background

         */
    }
    else if(applicationState == UIApplicationStateActive)
    {
        /*
         # App is currently active, can update badges count here
         // a push notification when the app is running. So that you can display an alert and push in any view

         */
    }
    else if(applicationState == UIApplicationStateBackground)
    {
        /* # App is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here */
        UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
        
        id topViewController = navigationController.topViewController;
        if ([topViewController isKindOfClass:[ViewController class]]) {
            [(ViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:nil];
        } else {
            NSLog(@"Not the right class %@.", [topViewController class]);
        }

    }

}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    _deviceToken = token;

    NSLog(@"content---%@",token );
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error---%@", error);

}

-(void)showAlert: (NSString *) message {
    UIAlertController *objAlertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                               NSLog(@"Ok clicked!");
                                                           }];
    
    [objAlertController addAction:cancelAction];
    
    
    [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] presentViewController:objAlertController animated:YES completion:^{
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count == 0)
        return;
    CLLocation* location = [locations lastObject];
//    //NSLog(@"latitude %+.6f, longitude %+.6f\n",
//          location.coordinate.latitude,
//          location.coordinate.longitude);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTaskId =
    [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTaskId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];

    dispatch_async( dispatch_get_main_queue(), ^{
//        self.timer = nil;
//        [self initTimer];
        [app endBackgroundTask:bgTaskId];
        bgTaskId = UIBackgroundTaskInvalid;
    });
    
//    [locationServices startMonitoringLocation];
    
    

}
- (void)initTimer {
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager startMonitoringSignificantLocationChanges];
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(checkUpdates:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}
- (void)checkUpdates:(NSTimer *)timer {
    UIApplication *app = [UIApplication sharedApplication];
    double remaining = app.backgroundTimeRemaining;
    if(remaining < 580.0) {
        [self.locationManager startUpdatingLocation];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

-(void)locationDataReceived:(DLLocationData *)location {
    
    NSLog(@"App Delegate User Location Data Readings: Latitude:%@,\nLongitude:%@,\nHAccuracy:%@,\nVAccuracy:%@.\nHeight:%@\nFloor:%@,\nFloorAccuracy:%@,\nLocationTime:%@",location.latitude,location.longitude,location.horizontalAccuracy,location.verticalAccuracy,location.height, location.floor,location.floorAccuracy,location.timestamp);
    
    NSDate *date = location.timestamp;
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
    NSDictionary *newdataSetInfo = [NSDictionary dictionaryWithObjectsAndKeys:location.latitude,@"latitude",location.longitude,@"longitude",location.verticalAccuracy,@"vAccuracy",location.horizontalAccuracy,@"hAccuracy",intervalString,@"timeStamp",location.height,@"height",nil];
    [self.locDataArray addObject:newdataSetInfo];
    NSDictionary *locDataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.locDataArray,@"location",nil];
    locationServices.uploadLocationdict = [NSDictionary dictionaryWithDictionary:locDataDict];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void) application:(UIApplication *)application
  performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    

    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
    id topViewController = navigationController.topViewController;
    if ([topViewController isKindOfClass:[ViewController class]]) {
        [(ViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:nil];
    } else {
        NSLog(@"Not the right class %@.", [topViewController class]);
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.dataLogger.app"];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    
    
//    NSData* data = [Your_json_string dataUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [[NSURL alloc] initWithString:locationRequet];
//    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:[NSURLRequest requestWithURL:url] fromData:@"" completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            completionHandler(UIBackgroundFetchResultFailed);
//            return;
//        }
//
//        // Parse response/data and determine whether new content was available
//        BOOL hasNewData = YES;
//        if (hasNewData) {
//            completionHandler(UIBackgroundFetchResultNewData);
//        } else {
//            completionHandler(UIBackgroundFetchResultNoData);
//        }
//
//    }];
//
//    // Start the task
//    [task resume];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   __block UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
//    [locationServices.manager stopMonitoringSignificantLocationChanges];
//    [locationServices getLocationContinuous];

    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        
        NSLog(@"Background updates are available for the app.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
