//
//  SuggestionVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "SuggestionVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AFHTTPRequestOperationManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <pthread.h>
#import <QuartzCore/QuartzCore.h>
#import "RatingViewController.h"

@interface SuggestionVC() <UISearchBarDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) NSInteger modeOfTransport;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geocoder;
@end

@implementation SuggestionVC

@synthesize geocoder;
@synthesize currentLocation;
@synthesize locationManager;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    [self setUpSearchBar];
    [self startUpdatingLocation];
}

- (void) startUpdatingLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.currentLocation = [[CLLocation alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    self.currentLocation = newLocation;
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lobster" size:40];
    label.textColor = [UIColor whiteColor];
    label.text = @"Venture";
    label.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = label;
}

- (void) setUpSearchBar {
    self.searchBar.hidden = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.searchBar.delegate = self;
}

- (IBAction)searchButtonClicked:(UIBarButtonItem *)sender {
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
     NSString *specifiedLoc = self.searchBar.text;
    
    [self.geocoder geocodeAddressString:specifiedLoc
         completionHandler:^(NSArray *placemarks, NSError *error) {
             if (!error) {
                 CLPlacemark *placemark = [placemarks firstObject];
                 self.currentLocation = placemark.location;
                 [self.locationManager stopUpdatingLocation];
                 NSLog(@"New loc: %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);

             } else {
                 NSLog(@"There was a forward geocoding error\n%@",
                       [error localizedDescription]);
             }
         }
     ];
    
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
}

- (IBAction)modeOfTransportButtonClicked:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Walk", @"Bike", @"Drive", @"Public Transport", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    self.modeOfTransport = buttonIndex;
}

@end






