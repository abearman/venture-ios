//
//  VentureViewController.m
//  Venture
//
//  Created by Amy Bearman on 4/11/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "VentureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>

@interface VentureViewController: UIViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *savedActivities;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeOfTransportation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityType;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *maybeButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation VentureViewController {
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
}

- (IBAction)getCurrentLocation:(UIButton *)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    /*if (currentLocation != nil) {
        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }*/
}

- (IBAction)searchButtonClicked:(id)sender {
    NSString *specifiedLoc = self.searchBar.text;
    [geocoder geocodeAddressString:specifiedLoc
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error) {
                         for(CLPlacemark *placemark in placemarks){
                             NSLog(@"%@",[placemark description]);
                             currentLocation = placemark.location; // Updates current location to their manual address
                         }
                     } else {
                         NSLog(@"There was a forward geocoding error\n%@",
                               [error localizedDescription]);
                     }
                 }
    ];
    
}

- (IBAction)yesButtonClicked:(id)sender {
    
}

- (IBAction)maybeButtonClicked:(id)sender {
    
}

- (IBAction)noButtonClicked:(id)sender {
    
}

@end

