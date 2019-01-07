//
//  MapViewController.h
//  DataLogger
//
//  Created by Abhilash Tyagi on 19/11/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) NSMutableArray * locDataArray;
@property (weak, nonatomic) IBOutlet UILabel *lblXpos;
@property (strong,nonatomic) NSArray * estlh;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrLocation;
@property (weak, nonatomic) IBOutlet UITextField *txtFldElevation;
@property (weak, nonatomic) IBOutlet UITextField *txtFldFloorNo;
@property (weak, nonatomic) IBOutlet UIButton *btnMyLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnMyBuildings;
@property (weak, nonatomic) IBOutlet UIButton *btnIndoor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segCtrl;

@end
