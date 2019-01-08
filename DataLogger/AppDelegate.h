//
//  AppDelegate.h
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <PushKit/PushKit.h>
#import <ARKit/ARKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,PKPushRegistryDelegate> {}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *isFirstTime;
@property (strong, nonatomic) NSMutableArray *arrResponse;
@property (strong, nonatomic) ARSCNView *sceneView;
@property (strong, nonatomic) NSString *arInitailiseTime;
@property (assign) BOOL isstartTest;
@property (strong, nonatomic) NSDictionary *dictCameraPosition;
-(void)initialiseAR;

@end

