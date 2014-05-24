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
#import "HomeModel.h"

@interface SuggestionVC() <UISearchBarDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

/* Model */
@property (strong, nonatomic) HomeModel *model;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger modeOfTransportation;
@property (nonatomic) NSInteger activityType;

/* Location */
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geocoder;

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *activityView;

@property (weak, nonatomic) IBOutlet UILabel *activityName;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating;
@property (strong, nonatomic) NSString *activityImgStr;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification;
@property (weak, nonatomic) IBOutlet UIImageView *ventureBotImageView;

@end

@implementation SuggestionVC

@synthesize geocoder;
@synthesize currentLocation;
@synthesize locationManager;

- (void) viewDidLoad {
    [super viewDidLoad];
    self.activityView.userInteractionEnabled = YES;
    
    self.modeOfTransportation = self.activityType = 0;
    [self setUpNavigationBar];
    [self setUpSearchBar];
    [self startUpdatingLocation];
    [self setUpGestureRecognizers];
    [self loadFirstSuggestion];
}

/*** LAZY INSTANTIATION OF OBJECTS ***/
- (HomeModel *)model {
    if (!_model) _model = [[HomeModel alloc] init];
    return _model;
}

/*** LOCATION STUFF ***/

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

/*** NAVIGATION BAR AND SEARCH BAR ***/

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

/*** MODE OF TRANSPORT ***/

- (IBAction)modeOfTransportButtonClicked:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Walk", @"Bike", @"Drive", @"Public Transport", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    self.modeOfTransportation = buttonIndex;
}

- (void) loadFirstSuggestion {
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    
    NSDictionary *parameters = @{@"deviceid": uuid};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Device" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = (NSDictionary *)(responseObject);
        self.userID = [[dict objectForKey:@"uid"] integerValue];
        
        //Loads first suggestion
        [self getNewActivity:self.modeOfTransportation atFeeling:self.activityType];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getNewActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling {
    [self.spinner startAnimating];
    [self.model downloadActivity:indexOfTransport atFeeling:indexOfFeeling withUser:self.userID atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude withCallback:^(VentureActivity* activity) {
        
        self.activityName.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityName.alpha = 1;}
                         completion:nil];
        self.activityName.text = activity.title;
        
        self.activityAddress.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityAddress.alpha = 1;}
                         completion:nil];
        self.activityAddress.text = activity.address;
        
        self.activityJustification.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityJustification.alpha = 1;}
                         completion:nil];
        self.activityJustification.text = activity.justification;
        
        self.activityImgStr = activity.imageURL;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.activityImgStr]];
        self.imageView.image = [UIImage imageWithData:imageData];
        self.imageView.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.imageView.alpha = 1;}
                         completion:nil];

        self.activityYelpRating.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityYelpRating.alpha = 1;}
                         completion:nil];
        NSString *yelpURL = activity.yelpRatingImageURL;
        NSData *imageDataYelp = [NSData dataWithContentsOfURL:[NSURL URLWithString:yelpURL]];
        self.activityYelpRating.image = [UIImage imageWithData:imageDataYelp];
        
        //Do google maps stuff to get time of travel and distance away
        CLLocation *loc1 = currentLocation;
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[activity.lat doubleValue] longitude:[activity.lng doubleValue]];
        
        double distance = [loc1 distanceFromLocation:loc2];
        distance /= 1000.0;
        
        self.activityDistanceAway.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityDistanceAway.alpha = 1;}
                         completion:nil];
        self.activityDistanceAway.text = [NSString stringWithFormat:@"%f km", distance];
        
        //stop spinner
        [self.spinner stopAnimating];

     }];
}

/*** GESTURE RECOGNIZERS ***/

- (void) setUpGestureRecognizers {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.activityView addGestureRecognizer:swipeRight];
    [self.activityView addGestureRecognizer:swipeUp];
    [self.activityView addGestureRecognizer:swipeLeft];
}

-(void)respondToSwipeLeft {
    /*if (indexActivitiesArray > 0) {
        //[imageView removeFromSuperview];
        NSLog(@"Swiped left");
        indexActivitiesArray--;
        NSLog(@"Index: %d", indexActivitiesArray);
        
        NSLog(@"Index: %d", indexActivitiesArray);
        [self getActivityAtIndex];
        self.savedActivity = [self.activities objectAtIndex:indexActivitiesArray];
    }*/
}

-(void)respondToSwipeRight {
    NSLog(@"Swiped right");
    [self getNewActivity:self.modeOfTransportation atFeeling:self.activityType];
}

-(void)respondToSwipeUp {
    /*[[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.title forKey:@"Saved Activity Title"];
    [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.imageURL forKey:@"Saved Activity Image"];
    [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.ID forKey:@"Saved Activity ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"%@", self.savedActivity.ID);
    
    NSString *destAddr;
    destAddr = [self.activityAddress.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *modeOfTransport;
    int index = [self.modeOfTransportation selectedSegmentIndex];
    if (index == 0) {
        modeOfTransport = @"walking";
    } else if (index == 1) {
        modeOfTransport = @"biking";
    } else if (index == 2) {
        modeOfTransport = @"driving";
    } else if (index == 3) {
        modeOfTransport = @"transit";
    }
    
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?origin=%f,%f&daddr=%@&center=%@,%@&directionsmode=%@&zoom=10", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, destAddr, activityLat, activityLng, modeOfTransport];
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:url]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }*/
}

@end






