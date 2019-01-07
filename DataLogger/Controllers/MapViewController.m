 //
//  MapViewController.m
//  DataLogger
//
//  Created by Abhilash Tyagi on 19/11/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "MapViewController.h"
#import "DataLoggerLocationServices.h"
#import "AppDelegate.h"
#import "FunctionUtil.h"
static int const ZOOM_LEVEL = 800;
@interface MapViewController ()<CLLocationManagerDelegate>
{
    MKPointAnnotation *point;
    MKPointAnnotation *point1;
    BOOL isMyLoc;
    BOOL isBuilding;
    BOOL isIndoor;
    NSString *timeElevInput;
    NSString *timeFloorInput;
    NSString *timeMapPan;
    NSString *mapSpan;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.showsScale = YES;

}
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == _mapView.userLocation)
    {
        return nil;
    }
    else if (annotation == point)
    {
        return nil;
    }
    else
    {
        static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
        MKAnnotationView* pinView = [mV dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        
        if (pinView == nil)
        {
            pinView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
            pinView.canShowCallout = YES;
        }
        else
        {
            pinView.annotation = annotation;
        }
        pinView.image = [UIImage imageNamed:@"marker"];
        
        return pinView;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([CLLocationManager locationServicesEnabled] )
    {
        if (self.locationManager == nil )
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        
        [self.locationManager startUpdatingLocation];
    }
    point = [[MKPointAnnotation alloc] init];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadAnnotation:)
     name:@"ReloadAnnotation"
     object:nil];
    [self btnMyLocClicked:self.btnMyLoc];
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self btnCurrentLocationClicked:self.btnCurrLocation];
        });
    }];
}
-(void)reloadAnnotation:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];

    dispatch_async(dispatch_get_main_queue(), ^{
        self->_estlh = [dict valueForKey:@"estL"];
        NSLog(@"Adding Annotation at %@,%@",self->_estlh[0],self->_estlh[1]);
        if(self->_estlh.count > 1)
        {
            self->_lblXpos.text = [NSString stringWithFormat:@"%.2f",[self->_estlh[2] doubleValue]];
        }
        [self addAnnotation];
    });
}
-(void)addAnnotation
{
    [self.mapView removeAnnotation:point];
    //convert NSNumber values to CLLocationCoordinate2D type
    CLLocationCoordinate2D annlocation;
    annlocation.latitude = [_estlh[0] doubleValue];
    annlocation.longitude = [_estlh[1]  doubleValue];
    
    //Add annotation to the mapview
    point.coordinate = annlocation;
//    point.title = [_estlh[0] stringValue];
//    point.subtitle = [_estlh[1] stringValue];
    [self.mapView addAnnotation:point];
   
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.isFirstTime  isEqual: @"true"])
    {
        //to show the regoin with radius = ZOOM_LEVEL
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annlocation, ZOOM_LEVEL, ZOOM_LEVEL);
         [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        region.center = annlocation;
        [self checkBuildingProperty];
        appDelegate.isFirstTime = @"false";
    }
    
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    
    // here we get the current location
}
- (IBAction)btnCurrentLocationClicked:(UIButton *)sender {

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,ZOOM_LEVEL, ZOOM_LEVEL);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    region.center = self.currentLocation.coordinate;

    if (isBuilding)
    {
        
        _mapView.showsBuildings = YES;
        MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
        mapCamera.pitch = 45;
        [mapCamera setCenterCoordinate:self.currentLocation.coordinate];
        mapCamera.altitude = 500; // example altitude
        mapCamera.heading = 45;

        
        // set the camera property
        _mapView.camera = mapCamera;
        
    }
    else
    {
        _mapView.showsBuildings = NO;
        MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
        mapCamera.pitch = 0;
        mapCamera.altitude = 500; // example altitude
        mapCamera.heading = 0;
        [mapCamera setCenterCoordinate:self.currentLocation.coordinate];
        
        // set the camera property
        _mapView.camera = mapCamera;
        
    }
   

}
- (IBAction)btnGTClicked:(UIButton *)sender {
    
//    if ([_txtFldFloorNo.text  isEqual: @""] )
//    {
//        [FunctionUtil showAlertViewWithTitle:@"Alert" andMessage:@"Please enter Floor Number." FromVc:self];
//    }
//    else if ([_txtFldElevation.text  isEqual: @""] )
//    {
//        [FunctionUtil showAlertViewWithTitle:@"Alert" andMessage:@"Please enter elevation." FromVc:self];
//
//    }
////    else if (point1 == nil)
////    {
////        [FunctionUtil showAlertViewWithTitle:@"Alert" andMessage:@"Please select location." FromVc:self];
////    }
//    else
//    {
        NSMutableDictionary *dictGT = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *arrResponse = [[NSMutableArray alloc]init];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"arrGroundTruth"] == nil)
        {
            arrResponse = [[NSMutableArray alloc]init];
        }
        else
        {
            arrResponse = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"arrGroundTruth"]];
        }
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
        
        [dictGT setObject:_txtFldElevation.text forKey:@"elevation"];
        [dictGT setObject:_txtFldFloorNo.text forKey:@"floor"];
        [dictGT setObject:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude] forKey:@"latitude"];
        [dictGT setObject:[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude] forKey:@"longitude"];
        [dictGT setObject:mapSpan forKey:@"mapZoomSpan"];
        [dictGT setObject:@"user_marker" forKey:@"source"];
        if (timeElevInput == nil || [timeElevInput isEqualToString:@""])
        {
            timeElevInput = intervalString;
        }
        if (timeFloorInput == nil || [timeFloorInput isEqualToString:@""])
        {
            timeFloorInput = intervalString;
        }
        if (timeMapPan == nil || [timeMapPan isEqualToString:@""])
        {
            timeMapPan = intervalString;
        }
        [dictGT setObject:timeElevInput forKey:@"timeElevInput"];
        [dictGT setObject:timeFloorInput forKey:@"timeFloorInput"];
        [dictGT setObject:timeMapPan forKey:@"timeMapPan"];
        [dictGT setObject:intervalString forKey:@"timeStamp"];
        [arrResponse addObject:dictGT];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrResponse forKey:@"arrGroundTruth"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _txtFldElevation.text = @"";
        _txtFldFloorNo.text = @"";
        mapSpan = @"";
        timeElevInput = @"";
        timeFloorInput = @"";
        timeMapPan = @"";
    
    NSLog(@"Tapped at lat: %f long: %f",_mapView.centerCoordinate.latitude,_mapView.centerCoordinate.longitude);
    [self.mapView removeAnnotation:point1];
    point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = _mapView.centerCoordinate;
    [self.mapView addAnnotation:point1];

//    }
    
}
- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated {
    
    MKCoordinateSpan span = _mapView.region.span;
    CLLocationCoordinate2D center = _mapView.region.center;
    CLLocation *loc3 = [[CLLocation alloc] initWithLatitude:center.latitude longitude:(center.longitude - span.longitudeDelta * 0.5)];
    CLLocation *loc4 = [[CLLocation alloc] initWithLatitude:center.latitude longitude:(center.longitude + span.longitudeDelta * 0.5)];
    int metersLongitude = [loc3 distanceFromLocation:loc4];

    mapSpan = [NSString stringWithFormat:@"%d", metersLongitude];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    timeMapPan = [NSString stringWithFormat:@"%f", timeStamp];
}

- (IBAction)btnPFLPClicked:(UIButton *)sender {
    if (_estlh != nil)
    {
        CLLocationCoordinate2D annlocation;
        annlocation.latitude = [_estlh[0] doubleValue];
        annlocation.longitude = [_estlh[1]  doubleValue];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annlocation, ZOOM_LEVEL, ZOOM_LEVEL);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        region.center = annlocation;
        [self checkBuildingProperty];
    }

}
- (IBAction)btnMyLocClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    isMyLoc = sender.selected;
    self.mapView.showsUserLocation = isMyLoc;
    [self.btnCurrLocation setHidden:!isMyLoc];
    [self checkBuildingProperty];
}

- (IBAction)btnBuildingsClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    isBuilding = sender.selected;
    [self checkBuildingProperty];
}

-(void)checkBuildingProperty
{
    if (isBuilding)
    {
        
        _mapView.showsBuildings = YES;
        MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
        mapCamera.pitch = 45;
        [mapCamera setCenterCoordinate:_mapView.centerCoordinate];
        mapCamera.altitude = 500;
        mapCamera.heading = 45;
        _mapView.camera = mapCamera;
        self.mapView.showsScale = YES;
    }
    else
    {
        _mapView.showsBuildings = NO;
        MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
        mapCamera.pitch = 0;
        mapCamera.altitude = 500;
        mapCamera.heading = 0;
        [mapCamera setCenterCoordinate:_mapView.centerCoordinate];
        _mapView.camera = mapCamera;
    }
}
- (IBAction)btnIndoorClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    isIndoor = sender.selected;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [UIView animateWithDuration:0.33 animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.window.frame = CGRectMake(0, -214, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        });
    }];

    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _txtFldElevation)
    {
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        timeElevInput = [NSString stringWithFormat:@"%f", timeStamp];
        
    }
    if (textField == _txtFldFloorNo)
    {
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        timeFloorInput = [NSString stringWithFormat:@"%f", timeStamp];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [UIView animateWithDuration:0.33 animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        });
    }];
    
    return YES;

}
- (IBAction)segCtrlClicked:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0)
    {
        //Map
        _mapView.mapType = MKMapTypeStandard;
        if (isBuilding)
        {
            
            _mapView.showsBuildings = YES;
            MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
            mapCamera.pitch = 45;
            [mapCamera setCenterCoordinate:self.currentLocation.coordinate];
            mapCamera.altitude = 500; // example altitude
            mapCamera.heading = 45;
            
            // set the camera property
            _mapView.camera = mapCamera;
            
        }
        else
        {
            _mapView.showsBuildings = NO;
            MKMapCamera *mapCamera = [[MKMapCamera alloc]init];
            mapCamera.pitch = 0;
            mapCamera.altitude = 0; // example altitude
            mapCamera.heading = 0;
            [mapCamera setCenterCoordinate:self.currentLocation.coordinate];
            
            // set the camera property
            _mapView.camera = mapCamera;
            
        }

    }
    else
    {
        //Satellite
        _mapView.mapType = MKMapTypeSatellite;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
