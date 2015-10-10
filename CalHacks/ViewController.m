//
//  ViewController.m
//  CalHacks
//
//  Created by Jack Connolly on 10/9/15.
//  Copyright © 2015 Jack Connolly. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL iOS8;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue] >= 8) {
        self.iOS8 = YES;
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(checkLocation) withObject:nil afterDelay:.5];
    
    
}


-(void)checkLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (self.iOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    
}

@end
