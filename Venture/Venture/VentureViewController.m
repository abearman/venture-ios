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
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
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


///////////////////////////////////

- (void) currentLocationIdentifier {
    //---- For getting current gps location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             NSLog(@"%@",CountryArea);
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             //CountryArea = NULL;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

- (IBAction)searchButtonClicked:(id)sender {
    
}

- (IBAction)yesButtonClicked:(id)sender {
    
}

- (IBAction)maybeButtonClicked:(id)sender {
    
}

- (IBAction)noButtonClicked:(id)sender {
    
}

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    
    /*if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    [locationManager startMonitoringSignificantLocationChanges];*/
}

@end

