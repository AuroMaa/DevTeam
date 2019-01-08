//
//  ViewController.m
//  DataLogger
//
//  Created by Madhu A on 7/18/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//
// http://demo-d1.polariswireless.com/HeartBeatAndRemoteConfig.php?HeartBeatVer=1&config_id=11
#define GET_METHOD_URL @"https://hacker-news.firebaseio.com/v0/topstories.json"
#define POST_METHOD_URL @"http://hayageek.com/examples/jquery/ajax-post/ajax-post.php"
#define IMAGEPATH @"http://photo-cult.com/pics/198/pic_9991609_0198027.jpg"


#import "ViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

#import "DataLoggerLocationServices.h"
#import "DLLocationData.h"
#import "DLUploadTestResultsData.h"
#import "ConnectionManager.h"
#import "HeartBeatRemoteConfig.h"

#import "FunctionUtil.h"
#import "constants.h"
#import "NSURL+URLQueryBuilder.h"
#import "MBProgressHUD.h"
#import "MapViewController.h"
#import <CoreMotion/CoreMotion.h>


static NSString * const KeychainItem_Service = @"DataLogger";
static NSString * const KeychainItem_SubscriberUUID = @"subscriberID";
static NSString * const KeychainItem_imeiIMEI = @"imei";
static NSString * const KeychainItem_imeiUUID = @"UUID";


@import UserNotifications;


API_AVAILABLE(ios(11.0))

@interface ViewController ()<DataLoggerLocationDelegate,settingsConfigChange,MBProgressHUDDelegate,UITextFieldDelegate,UNUserNotificationCenterDelegate,ARSessionDelegate> {
    HeartBeatRemoteConfig *heartBeatModel;
    NSTimer *apiUploadTimer;
    NSTimer *barometerTimer;
    NSString *pushDeviceToken;
    int testsCounter;
    BOOL collectBaroData;
    BOOL collectLocationData;
    BOOL removeANDfromQueryOnce;
    BOOL isAutomatedTestStarted;
    BOOL isAutoReportTestStarted;
    BOOL locationDataSetsCollected;
    BOOL BaroDataSetsCollected;
    BOOL pushNotificationRecieved;
    BOOL isRelaodClicked;
    DataLoggerLocationServices *sharedlocationServices;
    NSString *uuid;
    NSString *imei;
    NSString *subscriberID;
    NSString *updatedremoteConfigTestUrl;
    NSString *updatedconfigID;
    NSString *updatedBarometerRate;
    NSString *updatedLocationRate;
    NSString *updatedInitialDelay;
    NSString *updatedForegroundTestingUrl;
    NSString *updatedBackgroundTestingUrl;
    NSUserDefaults *defaults;
    MBProgressHUD *busyView;
    int currentCount;
    int receivedCount;
    int counter;
    NSTimer *baroBgTimer;
    NSTimer *locBgTimer;
    NSTimer *arTimer;

    BOOL isstartTest;
    NSDictionary *dictCameraPosition;
    NSString *arInitailiseTime;
}
@property (weak, nonatomic) IBOutlet UIButton *btnMap;

@property (nonatomic) NSUInteger interval;
@property (weak, nonatomic) IBOutlet UITextField *secondsIntervalTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *noOfTestTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *locationNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *subscriberIDTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *imeiTxtFld;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UITextField *uuidTxtFld;

@property (strong, nonatomic)HeartBeatRemoteConfig *modelClass;
@property (strong, nonatomic) DLUploadTestResultsData *resultModelData;
@property (strong,nonatomic) NSMutableArray * autoTestConfigArray;
@property (strong,nonatomic) NSMutableArray * baroDataArray;
@property (strong,nonatomic) NSMutableArray * locDataArray;
@property (strong,nonatomic) NSMutableDictionary *baroDataDict;
@property (strong,nonatomic) NSMutableArray * arDataArray;
@property (strong,nonatomic) NSDictionary *uploadbaroDataDict;
@property (strong,nonatomic) NSDictionary *uploadLocationdict;
@property (strong,nonatomic) SettingsViewController *settings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(serverUrlHasChanged:) name:@"serverUrlChanged" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadClicked) name:@"Reload" object:nil];
    
    
    collectBaroData = NO;
    collectLocationData = NO;
    removeANDfromQueryOnce = YES;
    pushNotificationRecieved = NO;
    sharedlocationServices = [DataLoggerLocationServices sharedManager];
    sharedlocationServices.delegate = self;
    self->isAutomatedTestStarted  = sharedlocationServices.isAutomatedTestStarted;
    self->isAutoReportTestStarted = sharedlocationServices.isAutoReportTestStarted;
    
    self.autoTestConfigArray = [[NSMutableArray alloc]init];
    self.baroDataArray = [[NSMutableArray alloc]init];
    self.locDataArray = [[NSMutableArray alloc]init];
    [self loadUpdatedConfigSettingsValues];
    //    subscriberID = [defaults objectForKey:@"SubscriberID"];
    
    if (!uuid&&!subscriberID) {
        if (self.imeiTxtFld.text.length == 0) {
            uuid = [self getUUIDforKey:KeychainItem_imeiUUID];
            subscriberID = [self getUUIDforKey:KeychainItem_SubscriberUUID];
            imei = [self getUUIDforKey:KeychainItem_imeiIMEI];
        }
    }
   //[FDKeychain deleteItemForKey:KeychainItem_imeiUUID forService:KeychainItem_Service error:nil];
  // [FDKeychain deleteItemForKey:KeychainItem_SubscriberUUID forService:KeychainItem_Service error:nil];
  //  [FDKeychain deleteItemForKey:KeychainItem_imeiIMEI forService:KeychainItem_Service error:nil];
    self.subscriberIDTxtFld.text=subscriberID;
    self.imeiTxtFld.text = imei;
    self.uuidTxtFld.text = uuid;
    self.locationNameTxtFld.text = @"TP";
    [sharedlocationServices startBarometer];
    [sharedlocationServices getLocationContinuous];
    busyView = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
    busyView.labelText = @"Loading Configuration";
    busyView.dimBackground = YES;
    busyView.delegate = self;
    [self performSelector:@selector(callHeartBeatAPI) withObject:pushDeviceToken afterDelay:3];
    //    [self callHeartBeatAPI];
    self.btnMap.enabled = NO;
}
- (void)reloadClicked
{
    isRelaodClicked=YES;
}

-(void)startLocationForBackground
{
    [sharedlocationServices startLocationForBackground];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadUpdatedConfigSettingsValues];
    SettingsViewController *settings = [[SettingsViewController alloc]init];
    settings.testingConfigDelegate = self;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Settings"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(pushSettingsPage)];
    self.navigationItem.rightBarButtonItem = settingsButton;
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Exit"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(aboutPage)];
//    self.navigationItem.leftBarButtonItem = aboutButton;
    self.navigationController.navigationBar.topItem.rightBarButtonItem = settingsButton;
//    self.navigationController.navigationBar.topItem.leftBarButtonItem = aboutButton;

    
}

-(void)loadUpdatedConfigSettingsValues {
    defaults = [NSUserDefaults standardUserDefaults];
    updatedremoteConfigTestUrl = [defaults objectForKey:@"HeartBeatTestUrl"];
    
    updatedInitialDelay = [defaults objectForKey:@"DelayinMS"];
    updatedBarometerRate = [defaults objectForKey:@"BaroUpdateRate"];
    updatedLocationRate = [defaults objectForKey:@"LocationUpdateRate"];
    updatedForegroundTestingUrl = [defaults objectForKey:@"ForegroundTestingUrl"];
    updatedBackgroundTestingUrl = [defaults objectForKey:@"BackgroundTestingUrl"];
    updatedconfigID = [defaults objectForKey:@"configId"];
    if(isRelaodClicked)
    {
        [self invalidateAllProcess];
        isRelaodClicked = NO;
        busyView = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
        busyView.labelText = @"Loading Configuration";
        busyView.dimBackground = YES;
        busyView.delegate = self;
        [self callHeartBeatAPI];
    }


}

-(void)aboutPage {
    exit(0);
}

-(void)serverUrlHasChanged:(NSNotification *)notification {
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:notification.object forKey:@"HeartBeatTestUrl"];
    [defaults synchronize];
    //    [[NSUserDefaults standardUserDefaults]setValue:notification.object forKey:@"HeartBeatTestUrl"];
}

-(void)settingsRemoteConfigValuesChangedfor:(NSString *)method withConfigValue:(NSString *)configValue {
    NSLog(@"HeartBeat Config Values Changed.");
    [defaults setValue:configValue forKey:method];
    [defaults synchronize];
    
}

-(void)pushSettingsPage {
    
    SettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"settingViewController"];
    vc.testingConfigDelegate = self;
    [self.navigationController pushViewController: vc animated:YES];
    
}

-(void) runBackgroundServices_ForAutoReporting {
    sharedlocationServices.isAutoReportTestStarted = YES;
    collectBaroData = YES;
    collectLocationData = YES;
    isAutoReportTestStarted=YES;
    [self upload_autoreport_services];
    
}

-(void)becameBackground {
    [sharedlocationServices startMonitoringLocation];
}
- (NSString *)getUUIDforKey:(NSString *)keyStr
{
    NSString *UUID = nil;
    
    if (![FDKeychain itemForKey: keyStr
                     forService: KeychainItem_Service
                          error: nil]) {
        if (keyStr == KeychainItem_imeiIMEI || keyStr == KeychainItem_SubscriberUUID)
        {
           return [self getUUIDforKey:KeychainItem_imeiUUID];
        }
        else
        {
            CFUUIDRef theUUID = CFUUIDCreate(NULL);
            CFStringRef string = CFUUIDCreateString(NULL, theUUID);
            CFRelease(theUUID);
            UUID=nil;
            UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
            [FDKeychain saveItem: UUID
                          forKey: keyStr
                      forService: KeychainItem_Service
                           error: nil];
        }
    }
    else {
        // CFUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
        UUID = [FDKeychain itemForKey: keyStr
                           forService: KeychainItem_Service
                                error: nil];
    }
    
    return UUID;
}

#pragma mark - RemoateHeartBeatAPI Call
  
-(void)callHeartBeatAPI {
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *uuidIMEI = self.imeiTxtFld.text;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    pushDeviceToken = appDelegate.deviceToken;  //..to read
    NSString *ulrString;
    if (!(updatedremoteConfigTestUrl.length == 0)) {
        if (!(updatedconfigID.length == 0)) {
            ulrString = [NSString stringWithFormat:@"%@HeartBeatVer=%d&config_id=%@&uuid=%@&devicetoken=%@",updatedremoteConfigTestUrl,1,updatedconfigID,uuidIMEI,pushDeviceToken];
        } else {
            ulrString = [NSString stringWithFormat:@"%@HeartBeatVer=%d&config_id=%d&uuid=%@&devicetoken=%@",updatedremoteConfigTestUrl,1,11,uuidIMEI,pushDeviceToken];
        }
    } else if (!(updatedconfigID.length == 0)) {
        int configID = [updatedconfigID intValue];
        ulrString = [NSString stringWithFormat:@"%@HeartBeatVer=%d&config_id=%d&uuid=%@&devicetoken=%@",hearBeatAPIURL,1,configID,uuidIMEI,pushDeviceToken];
    } else {
        ulrString = [NSString stringWithFormat:@"%@HeartBeatVer=%d&config_id=%d&uuid=%@&devicetoken=%@",hearBeatAPIURL,1,11,uuidIMEI,pushDeviceToken];
    }
    [ConnectionManager callGetMethod:ulrString completionBlock:^(BOOL succeeded, id responseData, NSString *errorMsg) {
        if (succeeded) {
            //NSLog(@"Data is %@",responseData);
            NSDictionary *dataDict = [[responseData objectForKey:@"remote"] objectForKey:@"setting"];
            if (dataDict!=nil) {
                self->heartBeatModel = [[HeartBeatRemoteConfig alloc]init];
                self->heartBeatModel.autoReportIntervalInSecs = [dataDict objectForKey:@"Auto_report_interval_in_secs"];
                self->heartBeatModel.testIntervalInSeconds = [dataDict objectForKey:@"Autotest_interval_in_secs"];
                self->heartBeatModel.testNumberOfTests = [dataDict objectForKey:@"Autotest_test_count"];
                self->heartBeatModel.testLocationName = [dataDict objectForKey:@"Autotest_location_name"];

                if (!(self->updatedBarometerRate.length == 0)) {
                    self->heartBeatModel.barometerUpdateRate = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Baro_update_rate_in_ms"];
                } else {
                    self->heartBeatModel.barometerUpdateRate = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Baro_update_rate_in_ms"];
                }
                if (!(self->updatedBarometerRate.length == 0)) {
                    self->heartBeatModel.locationUpdateRate = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Location_update_rate_in_ms"];
                } else {
                    self->heartBeatModel.locationUpdateRate = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Location_update_rate_in_ms"];
                }
                
                self->heartBeatModel.Vo_update_rate_in_ms = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Vo_update_rate_in_ms"];
                if (self->heartBeatModel.Vo_update_rate_in_ms == nil)
                {
                    self->heartBeatModel.Vo_update_rate_in_ms = [NSNumber numberWithInteger:[[self->defaults valueForKey:@"ARRate"] integerValue]];
                }
                self->heartBeatModel.initialDelay = [[dataDict objectForKey:@"Autotest"] objectForKey:@"Initial_delay"];
                [[HeartBeatRemoteConfig sharedConfigSettings].configValuesdict setDictionary:dataDict];
                [self.autoTestConfigArray addObject:self->heartBeatModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    [self loadAutomatedTestConfigValues];
                    [self->defaults setValue:self->heartBeatModel.autoReportIntervalInSecs forKey:@"autoReportIntervalInSecs"];
                    [self->defaults setValue:self->heartBeatModel.testIntervalInSeconds forKey:@"testIntervalInSeconds"];
                    [self->defaults setValue:self->heartBeatModel.testNumberOfTests forKey:@"testNumberOfTests"];
                    [self->defaults setValue:self->heartBeatModel.testLocationName forKey:@"testLocationName"];

                    [self->defaults setValue:self->updatedconfigID.length==0?@"11":self->updatedconfigID forKey:@"configId"];
                    [self->defaults setValue:[NSString stringWithFormat:@"%ld",(long)[self->heartBeatModel.initialDelay integerValue]] forKey:@"DelayinMS"];
                    [self->defaults setValue:[NSString stringWithFormat:@"%ld",(long)[self->heartBeatModel.barometerUpdateRate integerValue]] forKey:@"BaroUpdateRate"];
                    [self->defaults setValue:[NSString stringWithFormat:@"%ld",(long)[self->heartBeatModel.locationUpdateRate integerValue]] forKey:@"LocationUpdateRate"];
                    [self->defaults setBool:YES forKey:@"isNotFirstTime"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->busyView hide:YES];
                    [FunctionUtil showAlertViewWithTitle:@"Error" andMessage:@"Unsupported URL" FromVc:self];

                    if ([self->defaults boolForKey:@"isNotFirstTime"])
                    {
                        self->heartBeatModel = [[HeartBeatRemoteConfig alloc]init];
                        self->heartBeatModel.autoReportIntervalInSecs = [self->defaults objectForKey:@"autoReportIntervalInSecs"];
                        self->heartBeatModel.testIntervalInSeconds = [self->defaults objectForKey:@"testIntervalInSeconds"];
                        self->heartBeatModel.testNumberOfTests = [self->defaults objectForKey:@"testNumberOfTests"];
                        self->heartBeatModel.testLocationName = [self->defaults objectForKey:@"testLocationName"];
                        self->heartBeatModel.Vo_update_rate_in_ms = [NSNumber numberWithInteger:[[self->defaults valueForKey:@"ARRate"] integerValue]];
                        self->heartBeatModel.barometerUpdateRate = [NSNumber numberWithInteger:[[self->defaults objectForKey:@"BaroUpdateRate"] integerValue]];
                        self->heartBeatModel.locationUpdateRate = [NSNumber numberWithInteger:[[self->defaults objectForKey:@"LocationUpdateRate"] integerValue]];
                        self->heartBeatModel.initialDelay = [NSNumber numberWithInteger:[[self->defaults objectForKey:@"DelayinMS"] integerValue]];
                        [self.autoTestConfigArray addObject:self->heartBeatModel];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                            [self loadAutomatedTestConfigValues];
                        });
                    }
                    else
                    {
                        self->heartBeatModel = [[HeartBeatRemoteConfig alloc]init];
                        self->heartBeatModel.autoReportIntervalInSecs = [NSNumber numberWithInteger:600];
                        self->heartBeatModel.testIntervalInSeconds = [NSNumber numberWithInteger:5];
                        self->heartBeatModel.testNumberOfTests = [NSNumber numberWithInteger:7000];
                        self->heartBeatModel.barometerUpdateRate = [NSNumber numberWithInteger:250];
                        self->heartBeatModel.locationUpdateRate = [NSNumber numberWithInteger:4000];
                        self->heartBeatModel.initialDelay = [NSNumber numberWithInteger:1];
                        self->heartBeatModel.Vo_update_rate_in_ms = [NSNumber numberWithInteger:1000];

                        [self.autoTestConfigArray addObject:self->heartBeatModel];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                            [self loadAutomatedTestConfigValues];
                        });
                        
                        
                        [self->defaults setValue:@"1" forKey:@"DelayinMS"];
                        [self->defaults setValue:@"250" forKey:@"BaroUpdateRate"];
                        [self->defaults setValue:@"4000" forKey:@"LocationUpdateRate"];
                        [self->defaults setValue:@"1000" forKey:@"ARRate"];

                        self->updatedInitialDelay = [self->defaults objectForKey:@"DelayinMS"];
                        self->updatedBarometerRate = [self->defaults objectForKey:@"BaroUpdateRate"];
                        self->updatedLocationRate = [self->defaults objectForKey:@"LocationUpdateRate"];
                    }
                });
            }
            
        } else {
            [self->busyView hide:YES];
            [FunctionUtil showAlertViewWithTitle:@"Error" andMessage:errorMsg FromVc:self];
        }
    }];
}

-(void)loadAutomatedTestConfigValues {
    for (HeartBeatRemoteConfig * autoTestModel in self.autoTestConfigArray) {
        self.secondsIntervalTxtFld.text = [NSString stringWithFormat:@"%@",autoTestModel.testIntervalInSeconds];
        self.noOfTestTxtFld.text = [NSString stringWithFormat:@"%@",autoTestModel.testNumberOfTests];
        [busyView hide:YES];
        //self.locationNameTxtFld.text = autoTestModel.testLocationName;
    }
    self->isAutomatedTestStarted = sharedlocationServices.isAutomatedTestStarted;
    if (!isAutomatedTestStarted) {
        [self runBackgroundServices_ForAutoReporting];
    }
    
}

#pragma mark - AutomatedTest UserAction

- (IBAction)startTests:(UIButton *)sender {
    _lblTotal.text = [NSString stringWithFormat:@"Total : %@",self->_noOfTestTxtFld.text];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    BOOL checkLocationServices = [sharedlocationServices checkLocationStatus];
    if (!checkLocationServices) {
        [FunctionUtil showAlertViewWithTitle:@"Location Services" andMessage:@"Please Enable Location Services." FromVc:self];
        return;
    }
    if (sender.isSelected) {
        sender.selected=NO;
        isstartTest = NO;
        appDelegate.isstartTest = NO;
        if (isAutomatedTestStarted&&!isAutoReportTestStarted) {
            [sender setTitle:@"START TESTS" forState:UIControlStateNormal];
            if (isAutomatedTestStarted) {
                [self invalidateAllProcess];
            }
            isAutomatedTestStarted = NO;
            [self runBackgroundServices_ForAutoReporting];
            return;
        } else {
            [sender setTitle:@"START TESTS" forState:UIControlStateNormal];
            [self invalidateAllProcess];
            return;
        }

    } else {

        appDelegate.sceneView.hidden = NO;
        isstartTest = YES;
        appDelegate.isstartTest = YES;
        [sender setTitle:@"STOP TESTS" forState:UIControlStateNormal];
        sender.selected=YES;
        if (sharedlocationServices.isAutoReportTestStarted) {
            [self invalidateAllProcess];
            sharedlocationServices .isAutomatedTestStarted = NO;
            isAutomatedTestStarted = NO;
            isAutoReportTestStarted = NO;
        }
        
    }
    sharedlocationServices .delegate=self;
    
    if ((_secondsIntervalTxtFld.text && _secondsIntervalTxtFld.text.length > 0)&& (_noOfTestTxtFld.text && _noOfTestTxtFld.text.length > 0)&&(_locationNameTxtFld.text && _locationNameTxtFld.text.length > 0)&&(_subscriberIDTxtFld.text && _subscriberIDTxtFld.text.length > 0)&&(_imeiTxtFld.text && _imeiTxtFld.text.length > 0) ){
        int timeValue = [_secondsIntervalTxtFld.text intValue];
        testsCounter = 0;
        self.responseTextView.textColor=nil;
        self->isAutomatedTestStarted = NO;
        [self upload_TestResultsIn_TimeInterval:timeValue];
        [self startTestTimers];
    } else {
        if (isAutomatedTestStarted&&!isAutoReportTestStarted) {
            [sender setTitle:@"START TESTS" forState:UIControlStateNormal];
        }
        [FunctionUtil showAlertViewWithTitle:@"Alert" andMessage:@"All fields are Mandatory, please input the missing fields." FromVc:self];
    }
    [appDelegate initialiseAR];
    
    _arDataArray = [[NSMutableArray alloc]init];
    arTimer = [NSTimer scheduledTimerWithTimeInterval:[self->heartBeatModel.Vo_update_rate_in_ms intValue]/1000 repeats:true block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"Artime : %@",[NSDate date]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotification *myNotification = [NSNotification notificationWithName:@"ArKitValues"
                                                                           object:self
                                                                         userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:myNotification];
            
        });

        if (appDelegate.dictCameraPosition != nil)
        {
            [self->_arDataArray addObject:appDelegate.dictCameraPosition];
        }
    }];
    
}

#pragma mark - Automated & Auto Report Tests Main Timer

-(void)upload_autoreport_services {
    NSNumber *extractedExpr = self->heartBeatModel.autoReportIntervalInSecs;
    int autoReportInteval = [extractedExpr intValue];
    [self upload_TestResultsIn_TimeInterval:autoReportInteval];
}

-(void)upload_TestResultsIn_TimeInterval:(int )timeInterval {
    if(timeInterval<=0){
        return;
    }
    self.interval = timeInterval;
    if (isAutoReportTestStarted) {
        
        apiUploadTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                          target: self
                                                        selector:@selector(uploadBgTests)
                                                        userInfo: nil repeats:YES];
    }
    else
    {
        apiUploadTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                          target: self
                                                        selector:@selector(upload_TestResults_ToServer)
                                                        userInfo: nil repeats:YES];
        
    }
    [[NSRunLoop currentRunLoop] addTimer:apiUploadTimer forMode:NSDefaultRunLoopMode];
    
}
-(void)uploadBgTests
{
    [sharedlocationServices sendLocationDatafor_AutoReportService];
    
    [NSTimer scheduledTimerWithTimeInterval:0.005 repeats:NO block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->counter = self->counter + 1;
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
            NSLog(@"time baro1 : %@",intervalString);
            
            [self->sharedlocationServices sendBaroDatafor_AutoReportService];
            self->baroBgTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
                    NSLog(@"time baro  : %@",intervalString);
                    self->counter = self->counter + 1;
                    if (self->counter < 10)
                    {
                        [self->sharedlocationServices sendBaroDatafor_AutoReportService];
                    }
                    else
                    {
                        self->counter = 0;
                        [self->baroBgTimer invalidate];
                        [NSTimer scheduledTimerWithTimeInterval:0.005 repeats:NO block:^(NSTimer * _Nonnull timer2) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->sharedlocationServices sendLocationDatafor_AutoReportService];
                                [self upload_TestResults_ToServer];
                                [timer2 invalidate];
                            });
                        }];

                    }
                });
            }];
            
            [timer invalidate];    
        });
    }];
}

-(void)upload_TestResults_ToServer {
    collectBaroData = YES;
    collectLocationData = YES;
    NSLog(@"self->_arDataArray : %@",self->_arDataArray);
    if (isAutomatedTestStarted) {
        testsCounter++;
        NSLog(@"UploadTest Results %i",self->testsCounter);
        if (testsCounter==[_noOfTestTxtFld.text intValue]) {
            [apiUploadTimer invalidate];
            [sharedlocationServices invalidateTimers];
            [barometerTimer invalidate];
            barometerTimer = nil;
        }
        
    }
    NSDictionary *componentItems;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    componentItems = [self.uploadLocationdict objectForKey:@"location"];
    NSMutableDictionary *querydict = [[NSMutableDictionary alloc]init];
    NSDictionary *compdict;
    for (compdict in componentItems) {
        [querydict addEntriesFromDictionary:compdict];
        [querydict setObject:[compdict objectForKey:@"height"] forKey:@"alt"];
        [querydict removeObjectForKey:@"height"];
        [querydict setObject:[compdict objectForKey:@"hAccuracy"] forKey:@"acc"];
        [querydict removeObjectForKey:@"hAccuracy"];
        [querydict setObject:[compdict objectForKey:@"longitude"] forKey:@"long"];
        [querydict removeObjectForKey:@"longitude"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        NSDate* currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
        if ([intervalString length] > 0)
        {
            [querydict setValue:[NSNumber numberWithDouble:round(timeStamp * 1000)] forKey:@"request_time"];
//            [querydict setObject:[intervalString componentsSeparatedByString:@"."][0] forKey:@"request_time"];
        }
        //[querydict removeObjectForKey:@"timeStamp"];
        [querydict setObject:[compdict objectForKey:@"latitude"] forKey:@"lat"];
        [querydict removeObjectForKey:@"latitude"];
        [querydict removeObjectForKey:@"vAccuracy"];
        [querydict setObject:@"HLE" forKey:@"loc_engine"];
    }
    NSString *imeiStr = self.imeiTxtFld.text;
    NSString *subsID = self.subscriberIDTxtFld.text;
    NSString *locationID = self.locationNameTxtFld.text;
    [querydict setObject:imeiStr forKey:@"device_imei"];
    [querydict setObject:subsID forKey:@"device_imsi"];
    if (sharedlocationServices.isAutoReportTestStarted) {
        [querydict setObject:@"autoReport_Debug_No_Csv" forKey:@"location_id"];
    } else {
        [querydict setObject:locationID forKey:@"location_id"];
    }
    NSString *urlString;
    if (sharedlocationServices.isAutoReportTestStarted) {
        if (updatedBackgroundTestingUrl.length != 0 ) {
            urlString = [self addQueryStringToUrlString:updatedBackgroundTestingUrl withDictionary:querydict];
        } else {
            urlString = [self addQueryStringToUrlString:autoReportRequest withDictionary:querydict];
        }
    } else {
        if (updatedForegroundTestingUrl.length != 0) {
            urlString = [self addQueryStringToUrlString:updatedForegroundTestingUrl withDictionary:querydict];
        } else {
            urlString = [self addQueryStringToUrlString:locationRequet withDictionary:querydict];
        }
        
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSMutableArray  *autoReportLocArr = [NSMutableArray new];
    NSDictionary *di;
    if (sharedlocationServices.isAutoReportTestStarted) {
        NSArray *arr = [_uploadLocationdict objectForKey:@"location"];
        id firstObj = [arr firstObject];
        id lastObj = [arr lastObject];
        for ( id anEl in arr ) {
            if ( anEl == firstObj ){
                di = [arr firstObject];
                [autoReportLocArr addObject:di];
            } else if (anEl == lastObj){
                di = [arr lastObject];
                [autoReportLocArr addObject:di];
            }
        }
        NSDictionary *locDict = [NSDictionary dictionaryWithObjectsAndKeys:autoReportLocArr,@"location",nil];
        [dict addEntriesFromDictionary:locDict];
        [dict addEntriesFromDictionary:_uploadbaroDataDict];
        if ( [querydict objectForKey:@"request_time"] ) {
            [dict setObject:[querydict objectForKey:@"request_time"] forKey:@"timeStamp"];
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate* currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
            if ([intervalString length] > 0)
            {
                [dict setObject:[NSNumber numberWithDouble:round(timeStamp * 1000)] forKey:@"timeStamp"];
            }
            
        }
       /* NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
        [dict setObject:intervalString forKey:@"timeStamp"];*/
        NSLog(@"AutoReport Tests Request Data:%@",dict);
        
    } else {
        
        //--Filtering repeated Location and Barometer Data----////
        //        NSArray *locarr = [_uploadLocationdict objectForKey:@"location"];
        //        NSArray *bararr = [_uploadbaroDataDict objectForKey:@"barometer"];
        //        _uploadLocationdict = [self filterLocationData_BarometerData:locarr method:@"location"];
        //        _uploadbaroDataDict = [self filterLocationData_BarometerData:bararr method:@"barometer"];
        
        [dict addEntriesFromDictionary:_uploadbaroDataDict];
        [dict addEntriesFromDictionary:_uploadLocationdict];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableARKit"] == YES)
        {
            NSDictionary *arKitjsonDict = [NSDictionary dictionaryWithObjectsAndKeys:self.arDataArray,@"Arkit", nil];
            [dict addEntriesFromDictionary:arKitjsonDict];
        }
        NSMutableArray *arrGT = [[NSUserDefaults standardUserDefaults] valueForKey:@"arrGroundTruth"];
        if (arrGT != nil && arrGT.count > 0)
        {
            [dict setObject:arrGT forKey:@"user_marker"];
        }
      if ([querydict objectForKey:@"request_time"]) {
            [dict setObject:[querydict objectForKey:@"request_time"] forKey:@"timeStamp"];
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate* currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
            if ([intervalString length] > 0)
            {
                [dict setObject:[NSNumber numberWithDouble:round(timeStamp * 1000)] forKey:@"timeStamp"];
            }
        }
       /* NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
        [dict setObject:intervalString forKey:@"timeStamp"];*/
            NSLog(@"Automated Tests Request Data:%@",dict);
            NSLog(@"Automated Tests Request Data:%@",querydict);
        currentCount = currentCount+1;
        _lblCurrent.text = [NSString stringWithFormat:@"Current : %d",currentCount];

    }
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    //This code to send the string to request tab
    NSData * jsonData1 = [NSJSONSerialization dataWithJSONObject:querydict options:0 error:&err];
    NSString * params1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];

    if ([params1 length] > 0) {
        params1 = [params1 substringToIndex:[params1 length] - 1];
    } else {
        //no characters to delete... attempting to do so will result in a crash
    }

    params1 = [params1 stringByAppendingString:@","];
    params1 = [params1 stringByAppendingString:params];
    params1 = [params1 stringByAppendingString:@"}"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"params1 : %@",params1);
        NSMutableDictionary *dictjson = [[NSMutableDictionary alloc]init];
        [dictjson setValue:params1 forKey:@"json"];
        
        //UUID,IMEI,IMSI,Log_start_time
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH_mm";
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];

        NSString *strFileName = [[NSString alloc]initWithFormat:@"%@_%@_%@_%@",self.uuidTxtFld.text,self.imeiTxtFld.text,self.subscriberIDTxtFld.text,strDate];
        
//        NSError *error = nil;
//        NSData *dataFromDict = [NSJSONSerialization dataWithJSONObject:dictjson
//                                                                   options:NSJSONWritingPrettyPrinted
//                                                                     error:&error];
        

//        [self saveRequestToTextfileWith:dataFromDict WithFileName:strFileName];
        [self saveRequestToTextfileWith:params1.description WithFileName:strFileName];
        NSNotification *myNotification = [NSNotification notificationWithName:@"request"
                                                                       object:self //object is usually the object posting the notification
                                                                     userInfo:dictjson]; //userInfo is an optional dictionary
        
        //Post it to the default notification center
        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    });

    
    [self refreshStoredData];
    [ConnectionManager callPostMethod:urlString withDelegate:self parameters:params completionBlock:^(BOOL succeeded, NSData *responseData, NSString *errorMsg) {
        if (succeeded) {
            //removing the groundtruth values to add only new values
            [[NSUserDefaults standardUserDefaults] setValue:[[NSMutableArray alloc]init] forKey:@"arrGroundTruth"];
            NSError *error = nil;
            NSDictionary *jsondict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSDictionary *ResultsDict = [jsondict objectForKey:@"response"];
            self.resultModelData = [[DLUploadTestResultsData alloc]initWithDictionary:ResultsDict error:&error];
            NSDictionary *deviceDetails = self.resultModelData.device;
            NSString *imsiString;
            NSString *estLString;
            NSString *groundStr;
            NSArray *estL = self.resultModelData.estLlh;
            [self->defaults setObject:estL forKey:@"estL"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_arDataArray removeAllObjects];
                NSLog(@"Adding Annotation at post %@,%@",estL[0],estL[1]);
                NSMutableDictionary *dictEstl = [[NSMutableDictionary alloc]init];
                [dictEstl setValue:estL forKey:@"estL"];
                NSNotification *myNotification = [NSNotification notificationWithName:@"ReloadAnnotation"
                                                                               object:self //object is usually the object posting the notification
                                                                             userInfo:dictEstl]; //userInfo is an optional dictionary
                
                //Post it to the default notification center
                [[NSNotificationCenter defaultCenter] postNotification:myNotification];
            });
            //code for showing responses
            if (self.resultModelData != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *dictRes = [[NSMutableDictionary alloc]init];
                  NSMutableArray *arrResponse = [self deleteExcessObjectsinResultArray];
                    if (arrResponse == nil)
                    {
                        arrResponse = [[NSMutableArray alloc] init];
                    }
                    else
                    {
                        [arrResponse addObject:responseData];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:arrResponse forKey:@"arrResponse"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [dictRes setValue:self.resultModelData forKey:@"response"];
                    NSNotification *resNotification = [NSNotification notificationWithName:@"ResponseReceived"
                                                       object:self //object is usually the object posting the notification
                                                       userInfo:dictRes]; //userInfo is an optional dictionary
                    //Post it to the default notification center
                    [[NSNotificationCenter defaultCenter] postNotification:resNotification];
                });
            }
            estLString = [NSString stringWithFormat:@"estLlh : %@",[estL componentsJoinedByString:@", "]];
            imsiString = [NSString stringWithFormat:@"device imsi : %@",[deviceDetails objectForKey:@"imsi"]];
            NSDictionary *groundtruth = self.resultModelData.groundtruth;
            groundStr = [NSString stringWithFormat:@"time : %@, request_time_unix : %@",[groundtruth objectForKey:@"time"],[groundtruth objectForKey:@"request_time_unix"]];
            if (applicationState != UIApplicationStateBackground) {
                if (!self->isAutoReportTestStarted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->receivedCount = self->receivedCount+1;
                        self->_lblReceived.text = [NSString stringWithFormat:@"Received : %d",self->receivedCount];
                        self.btnMap.enabled = YES;
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        self.responseTextView.hidden=NO;
                        self.responseTextView.text = [NSString stringWithFormat:@"TEST %d RESPONSE:\n %@ \n horzUnc :%@ \n vertUnc : %@ \n provider : %@ \n %@ \n ground %@ \n location_id : %@ \n message : %@ \n request_start_time : %@ \n request_received_time : %@ \n time_to_fix : %@ \n request_respond_time : %@",self->testsCounter,estLString,self.resultModelData.horzUnc,self.resultModelData.vertUnc,self.resultModelData.provider,imsiString,groundStr,self.resultModelData.location_id,self.resultModelData.message,self.resultModelData.request_start_time,self.resultModelData.request_received_time,self.resultModelData.time_to_fix,self.resultModelData.request_respond_time];
                        [self startTestTimers];
                    });
                    
                }
                
            }else {
                if (self->pushNotificationRecieved) {
                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                    content.title = @"Background Update";
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
                    NSString *result = [formatter stringFromDate:[NSDate date]];
                    
                    content.body = [NSString stringWithFormat:@"Location Auto Report under progress Launched at time:%@",result];
                    content.sound = [UNNotificationSound defaultSound];
                    NSString *identifier = @"UYLLocalNotification";
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                          content:content trigger:nil];
                    
                    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                        if (error != nil) {
                            //NSLog(@"Something went wrong: %@",error);
                        }
                    }];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    NSLog(@"Push Notification Response Dict: %@", jsondict);
                    
                }
                //                UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                //                content.title = @"Background Update";
                //                content.body = @"Location Auto Report under progress.";
                //                content.sound = [UNNotificationSound defaultSound];
                //                NSString *identifier = @"UYLLocalNotification";
                //                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                //                                                                                      content:content trigger:nil];
                //
                //                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                //                    if (error != nil) {
                //                        NSLog(@"Something went wrong: %@",error);
                //                    }
                //                }];
            }
            
            if (error != nil) {
                NSLog(@"Error parsing JSON.");
                self->receivedCount = self->receivedCount-1;
                self->_lblReceived.text = [NSString stringWithFormat:@"Received : %d",self->receivedCount];

                self.responseTextView.text=nil;
                self.responseTextView.hidden = YES;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            }
            else {
                //                NSLog(@"Dict: %@", jsondict);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            }
            
            
        } else {
            NSLog(@"Error Results %@",errorMsg);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [FunctionUtil showAlertViewWithTitle:@"Error" andMessage:errorMsg FromVc:self];
        }
    }];
}
//-(void) saveRequestToTextfileWith:(NSData*)req WithFileName:(NSString*)filename{

-(void) saveRequestToTextfileWith:(NSString*)strReq WithFileName:(NSString*)filename{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Requests"];
    NSFileManager *fMangaer  = [NSFileManager defaultManager];
    if ([fMangaer fileExistsAtPath:documentsDirectory] == NO)
    {
        NSError *err = nil;
        if ([fMangaer createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&err] == NO)
        {
            NSLog(@"Unable to create Directory at : %@ due to %@",documentsDirectory,err);
        }
        else
        {
            NSLog(@"Directory created Successfully at : %@",documentsDirectory);
        }
    }
    else
    {
        NSLog(@"Directory already Exists at : %@",documentsDirectory);
    }

    NSString *fileName1 = [NSString stringWithFormat:@"%@/%@.txt",
                           documentsDirectory,filename];

    strReq = [strReq stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    strReq = [strReq stringByReplacingOccurrencesOfString:@"," withString:@",\n"];
    strReq = [strReq stringByReplacingOccurrencesOfString:@"{" withString:@"{\n"];
    strReq = [strReq stringByReplacingOccurrencesOfString:@"}" withString:@"\n}\n"];
    strReq = [strReq stringByReplacingOccurrencesOfString:@"{\n\n    json = \"" withString:@""];
    strReq = [strReq stringByReplacingOccurrencesOfString:@"\";\n}" withString:@""];
    [strReq writeToFile:fileName1
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];

//        [req writeToFile:fileName1 atomically:YES];
}

-(NSMutableArray*)deleteExcessObjectsinResultArray
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"ResultCount"] == nil)
    {
        return [[NSMutableArray alloc]init];
    }
    NSMutableArray *arrResponse = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"arrResponse"]];
    do {
        if (arrResponse.count >= [[[NSUserDefaults standardUserDefaults] valueForKey:@"ResultCount"] integerValue])
        {
            if (arrResponse.count > 0)
            {
                [arrResponse removeObjectAtIndex:0];
                [[NSUserDefaults standardUserDefaults] setObject:arrResponse forKey:@"arrResponse"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }

    } while (arrResponse.count >= [[[NSUserDefaults standardUserDefaults] valueForKey:@"ResultCount"] integerValue]);
        return arrResponse;
    

}

#pragma mark - Location & Baro Update Rate Timers

-(void)startTestTimers {
    self.baroDataArray = [[NSMutableArray alloc]init];
    self.locDataArray = [[NSMutableArray alloc]init];
    int initialDelay;
    int barometerInterval;
    int locationInterval;
    if (!(updatedInitialDelay.length == 0)) {
        initialDelay = [updatedInitialDelay intValue];
    } else {
        initialDelay = [self->heartBeatModel.initialDelay intValue];
    }
    if (!(updatedBarometerRate.length == 0)) {
        barometerInterval = [updatedBarometerRate intValue];
    } else {
        barometerInterval = [self->heartBeatModel.barometerUpdateRate intValue];
    }
    if (!(updatedLocationRate.length == 0)) {
        locationInterval = [updatedLocationRate intValue];
    } else {
        locationInterval = [self->heartBeatModel.locationUpdateRate intValue];
    }
    
    
    collectBaroData = YES;
    collectLocationData = YES;
    self->isAutomatedTestStarted = YES;
    [sharedlocationServices getLocationforTimeInterval:locationInterval withInitialDelayOfInterval:initialDelay];
    [sharedlocationServices getBarometerReadings_forInterval:barometerInterval withInitialDelayOfInterval:initialDelay];
    
}
-(void)invalidateAllProcess {
    [apiUploadTimer invalidate];
    apiUploadTimer = nil;
    [sharedlocationServices invalidateTimers];
    [barometerTimer invalidate];
    barometerTimer = nil;
    [baroBgTimer invalidate];
    baroBgTimer = nil;
    self.responseTextView.text=nil;
    sharedlocationServices .isAutoReportTestStarted = NO;
    sharedlocationServices .isAutomatedTestStarted = NO;
    isAutoReportTestStarted=NO;
    isAutomatedTestStarted = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (void)insertNewObjectForFetchWithCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"Push Notification->Upload Tests Data");
    if (isAutomatedTestStarted) {
        return;
    }
    // Amar Commented out. - Fix for Push notification
    //    else if (isAutoReportTestStarted) {
    //        return;
    //    }
    else {
        isAutoReportTestStarted = YES;
        pushNotificationRecieved = YES;
        sharedlocationServices.isAutoReportTestStarted=YES;
//        [sharedlocationServices sendBaroDatafor_AutoReportService];
//        [sharedlocationServices sendLocationDatafor_AutoReportService];
        [self uploadBgTests];
    }
    
    /*
     At the end of the fetch, invoke the completion handler.
     */
    //    completionHandler(UIBackgroundFetchResultNewData);
    
}




-(id)filterLocationData_BarometerData:(NSArray *)arr method:(NSString *)str{
    
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    NSMutableArray *filteredLocArr = [[NSMutableArray alloc] init];
    NSUInteger objectindex = 0;
    for (NSDictionary *userDict in arr) {
        
        if (![usernames containsObject:userDict]) {
            [usernames addObject:userDict];
            [filteredLocArr addObject:userDict];
        } else {
            id objIdx = [arr objectAtIndex:objectindex];
            NSUInteger indexOfFirstInstance = [usernames indexOfObject:objIdx];
            NSMutableDictionary *entry = [[filteredLocArr objectAtIndex:indexOfFirstInstance] mutableCopy];
            [entry setValue:[[entry objectForKey:@"text"] stringByAppendingString:[NSString stringWithFormat:@", %@", [userDict objectForKey:@"text"]]] forKey:@"text"];
            [filteredLocArr replaceObjectAtIndex:indexOfFirstInstance withObject:entry];
            
        }
        objectindex++;
    }
    NSDictionary *filteredDict;
    if ([str isEqualToString:@"location"]) {
        filteredDict = [NSDictionary dictionaryWithObjectsAndKeys:filteredLocArr,@"location", nil];
    } else {
        filteredDict = [NSDictionary dictionaryWithObjectsAndKeys:filteredLocArr,@"barometer", nil];
    }
    
    return filteredDict;
    
}


-(NSString*)urlEscapeString:(NSString *)unencodedString
{
    //    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    //    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
    NSString *ss = [unencodedString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    //    CFRelease(originalStringRef);
    return ss;
}
-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            if (removeANDfromQueryOnce) {
                [urlWithQuerystring appendFormat:@"%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
                removeANDfromQueryOnce = NO;
            } else {
                [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
            }
            
        }
    }
    return urlWithQuerystring;
}

-(void)barometerDataReceived:(NSNumber *)barometerAirPressure relativedata:(NSNumber *)altitude timeStamp:(NSNumber *)time {
    NSLog(@"Barometer Readings:%@,%@,%@",barometerAirPressure,altitude,time);
}
-(void)barometerDataReceived:(DLBarometerData *)barometerReadings {
    //    NSLog(@"Barometer Readings:%@",barometerReadings.timestamp);
    if (barometerReadings!=nil) {
        if (collectBaroData) {
            
            //----converting pressure from kpa unit to hpa unit-----//
            NSNumber *presVal = barometerReadings.airPressure;
            double pressure = [presVal doubleValue];
            double b = 10 ;
            double c = pressure * b;
            NSNumber *hpaUnitVal = [NSNumber numberWithDouble:c];
            
            //-----converting barometer timestamp into unix format (POSIX)----//
//            NSTimeInterval interval = [barometerReadings.timestamp doubleValue];
//            NSDate *barodate = [NSDate dateWithTimeInterval:interval sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate* currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];

            NSDictionary * newdataSetInfo = [NSDictionary dictionaryWithObjectsAndKeys:hpaUnitVal,@"pressure",barometerReadings.relativeAltitude,@"altitude",[intervalString length] > 0 ? [NSNumber numberWithDouble:round(timeStamp * 1000)] : [NSNumber numberWithDouble:0.0],@"time", nil];
            if (self.baroDataArray.count <= 10) {
                [self.baroDataArray addObject:newdataSetInfo];
                NSDictionary *barojsonDict = [NSDictionary dictionaryWithObjectsAndKeys:self.baroDataArray,@"barometer", nil];
                self.uploadbaroDataDict = [NSDictionary dictionaryWithDictionary:barojsonDict];
            }
            else {
                BaroDataSetsCollected = YES;
            }
        }
    }
    
    
}
-(void)BaroUpdateForBgService:(DLBarometerData *)data
{
    //----converting pressure from kpa unit to hpa unit-----//
    NSNumber *presVal = data.airPressure;
    double pressure = [presVal doubleValue];
    double b = 10 ;
    double c = pressure * b;
    NSNumber *hpaUnitVal = [NSNumber numberWithDouble:c];
    
    //-----converting barometer timestamp into unix format (POSIX)----//
    NSTimeInterval interval = [data.timestamp doubleValue];
    NSDate *barodate = [NSDate dateWithTimeInterval:interval sinceDate:[NSDate date]];
    NSTimeInterval timeStamp = [barodate timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
    
    NSDictionary * newdataSetInfo = [NSDictionary dictionaryWithObjectsAndKeys:hpaUnitVal,@"pressure",data.relativeAltitude,@"altitude",[NSNumber numberWithDouble:round(timeStamp * 1000)],@"time", nil];
    if (self.baroDataArray.count < 10) {
        [self.baroDataArray addObject:newdataSetInfo];
    }
    else
    {
        NSDictionary *barojsonDict = [NSDictionary dictionaryWithObjectsAndKeys:self.baroDataArray,@"barometer", nil];
        self.uploadbaroDataDict = [NSDictionary dictionaryWithDictionary:barojsonDict];
        [baroBgTimer invalidate];
        [sharedlocationServices startLocationForBackground];
    }
}
-(void)locationUpdateForBgService:(DLLocationData *)data
{
    NSDate *date = data.timestamp;
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];
    NSDictionary *newdataSetInfo = [NSDictionary dictionaryWithObjectsAndKeys:data.latitude,@"latitude",data.longitude,@"longitude",data.verticalAccuracy,@"vAccuracy",data.horizontalAccuracy,@"hAccuracy",[NSNumber numberWithDouble:round(timeStamp * 1000)],@"timeStamp",data.height,@"height",nil];
    [self.locDataArray addObject:newdataSetInfo];
    [[sharedlocationServices manager] stopUpdatingLocation];
    [NSTimer scheduledTimerWithTimeInterval:9.005 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self->baroBgTimer invalidate];
        [self->sharedlocationServices startLocationForBackground];
        if (self.locDataArray.count >= 2)
        {
            if (self.locDataArray.count > 2)
            {
                NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
                [arrTemp addObject:self.locDataArray[0]];
                [arrTemp addObject:self.locDataArray[1]];
                [self.locDataArray removeAllObjects];
                [self.locDataArray addObjectsFromArray:arrTemp];
            }
            NSDictionary *locDataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.locDataArray,@"location",nil];
            self.uploadLocationdict = [NSDictionary dictionaryWithDictionary:locDataDict];
            
            return;
        }

        [timer invalidate];
    }];

    if([CMAltimeter isRelativeAltitudeAvailable])
    {
        [NSTimer scheduledTimerWithTimeInterval:0.005 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self->sharedlocationServices startBarometerForBgService];
            [timer invalidate];
        }];
        
        baroBgTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self->sharedlocationServices startBarometerForBgService];
        }];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:10.010 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self->sharedlocationServices startLocationForBackground];
            [timer invalidate];
        }];
        
        
    }
}

- (void)locationDataReceived:(DLLocationData *)location {
    if (location!=nil) {
        if (collectLocationData) {
            //            NSLog(@"User Location Data Readings: Latitude:%@,\nLongitude:%@,\nHAccuracy:%@,\nVAccuracy:%@.\nHeight:%@\nFloor:%@,\nFloorAccuracy:%@,\nLocationTime:%@",location.latitude,location.longitude,location.horizontalAccuracy,location.verticalAccuracy,location.height, location.floor,location.floorAccuracy,location.timestamp);
            
            NSDate *date = location.timestamp;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            NSDate* currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp * 1000];

            NSDictionary *newdataSetInfo = [NSDictionary dictionaryWithObjectsAndKeys:location.latitude,@"latitude",location.longitude,@"longitude",location.verticalAccuracy,@"vAccuracy",location.horizontalAccuracy,@"hAccuracy",[intervalString length] > 0 ? [NSNumber numberWithDouble:round(timeStamp * 1000)] : [NSNumber numberWithDouble:0.0] ,@"timeStamp",location.height,@"height",nil];
            if (isAutomatedTestStarted) {
                [self.locDataArray addObject:newdataSetInfo];
                NSDictionary *locDataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.locDataArray,@"location",nil];
                self.uploadLocationdict = [NSDictionary dictionaryWithDictionary:locDataDict];
                
            } else {
                if (self.locDataArray.count <=5) {
                    [self.locDataArray addObject:newdataSetInfo];
                    NSDictionary *locDataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.locDataArray,@"location",nil];
                    self.uploadLocationdict = [NSDictionary dictionaryWithDictionary:locDataDict];
                } else {
                    locationDataSetsCollected = YES;
                }
            }
            
            
        }
    }
    
    
}

-(void)refreshStoredData {
    [self.locDataArray removeAllObjects];
    [self.baroDataArray  removeAllObjects];
    self.uploadbaroDataDict = nil;
    self.uploadLocationdict = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == _imeiTxtFld) {
        if (textField.text != uuid) {
            NSString *updatedIMEI = textField.text;
            [FDKeychain saveItem: updatedIMEI
                          forKey: KeychainItem_imeiUUID
                      forService: KeychainItem_Service
                           error: nil];
        }
    } else if (textField == _subscriberIDTxtFld) {
        if (textField.text != subscriberID) {
            NSString *updatedSubscriberID = textField.text;
            [FDKeychain saveItem: updatedSubscriberID
                          forKey: KeychainItem_SubscriberUUID
                      forService: KeychainItem_Service
                           error: nil];
            
        }
    }
    
}

- (IBAction)btnGoTOMapviewClicked:(UIButton *)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    controller.locDataArray = [[NSMutableArray alloc]initWithArray:self.locDataArray];
    controller.estlh = self.resultModelData.estLlh;
    [self.navigationController pushViewController:controller animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

