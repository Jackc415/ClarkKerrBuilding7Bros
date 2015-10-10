//
//  ViewController.m
//  CalHacks
//
//  Created by Jack Connolly on 10/9/15.
//  Copyright © 2015 Jack Connolly. All rights reserved.
//

#import "ViewController.h"
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController () <PFLogInViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (nonatomic) BOOL iOS8;
@property (nonatomic) int currentCategoryIndex;
@property (weak, nonatomic) NSTimer *updateLocationTimer;
@property (strong, nonatomic) NSArray *availableActivities;
@property (strong, nonatomic) NSArray *categoryLabels;
@end

typedef NS_ENUM(uint8_t, PFUIDemoType) {
    PFUIDemoTypeSimpleTable,
    PFUIDemoTypePaginatedTable,
    PFUIDemoTypeSectionedTable,
    PFUIDemoTypeStoryboardTable,
    PFUIDemoTypeDeletionTable,
    PFUIDemoTypeSimpleCollection,
    PFUIDemoTypePaginatedCollection,
    PFUIDemoTypeSectionedCollection,
    PFUIDemoTypeStoryboardCollection,
    PFUIDemoTypeDeletionCollection,
    PFUIDemoTypeLogInDefault,
    PFUIDemoTypeLogInUsernamePassword,
    PFUIDemoTypeLogInPasswordForgotten,
    PFUIDemoTypeLogInDone,
    PFUIDemoTypeLogInEmailAsUsername,
    PFUIDemoTypeLogInFacebook,
    PFUIDemoTypeLogInFacebookAndTwitter,
    PFUIDemoTypeLogInAll,
    PFUIDemoTypeLogInAllNavigation,
    PFUIDemoTypeLogInCustomizedLogoAndBackground,
    PFUIDemoTypeSignUpDefault,
    PFUIDemoTypeSignUpUsernamePassword,
    PFUIDemoTypeSignUpUsernamePasswordEmail,
    PFUIDemoTypeSignUpUsernamePasswordEmailSignUp,
    PFUIDemoTypeSignUpAll,
    PFUIDemoTypeSignUpEmailAsUsername,
    PFUIDemoTypeSignUpMinPasswordLength,
    PFUIDemoTypeImageTableDefaultStyle,
    PFUIDemoTypeImageTableSubtitleStyle,
    PFUIDemoTypeImageCollection,
    PFUIDemoTypePurchase,
    PFUIDemoTypeCustomizedPurchase
};

@implementation ViewController

- (IBAction)swipeRIght:(UISwipeGestureRecognizer *)sender {
    
    [self afterSwipeFunctionRight:YES];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    
    [self afterSwipeFunctionRight:NO];
}

-(void)afterSwipeFunctionRight:(BOOL)right{
    
    if (right) {
        NSLog(@"Woah its right");
        self.currentCategoryIndex--;
        if (self.currentCategoryIndex < 0) {
            self.currentCategoryIndex = (int)self.categoryLabels.count-1;
        }
    }
    else{
        NSLog(@"Woah its left");
        
        self.currentCategoryIndex++;
        if (self.currentCategoryIndex >= (int)self.categoryLabels.count) {
            self.currentCategoryIndex = 0;
        }
        
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue] >= 8) {
        self.iOS8 = YES;
    }
    self.currentCategoryIndex = 0;
    self.categoryLabels = @[@"Social", @"Study", @"Netflix and Chill"];
    [self updateCategoryLabels];
    self.mapView.delegate = self;
    [self performSelector:@selector(checkLocation) withObject:nil afterDelay:.5];
    // Do any additional setup after loading the view, typically from a nib.
    
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}

-(void)updateCategoryLabels{
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:self.categoryView.frame];
    firstLabel.text = [self.categoryLabels objectAtIndex:self.currentCategoryIndex];
    
    
}

-(void)checkLocation{
    if (![PFUser currentUser]) {
        [PFFacebookUtils logInInBackgroundWithReadPermissions:nil block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
            }
        }];
    }
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (self.iOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    if (!self.updateLocationTimer) {
        self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(repeatThisFunction) userInfo:nil repeats:YES];
        [self.updateLocationTimer fire];
    }
    
    
    
}

-(void)repeatThisFunction{
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        
        if (self.iOS8) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Turn on Location Services"
                                                            message:@"To start a party, turn on location services."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings",nil];
            [alert show];
        }
        
    }
    
}

-(void)findNearParties:(PFGeoPoint*)geoPoint{
    // Create a query for places
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"WhatUpActivities"];
    // Interested in locations near user.
    [query whereKey:@"Location" nearGeoPoint:geoPoint withinMiles:2];
    // Limit what could be a lot of points.
    query.limit = 20;
    // Final list of objects
    
    self.availableActivities = [query findObjects];
    
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.01;
    mapRegion.span.longitudeDelta = 0.01;
    
    [mapView setRegion:mapRegion animated:TRUE];
    [mapView regionThatFits:mapRegion];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:mapView.userLocation.coordinate.latitude longitude:mapView.userLocation.coordinate.longitude];
    
    [self performSelectorInBackground:@selector(findNearParties:) withObject:geoPoint];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    
}



@end
