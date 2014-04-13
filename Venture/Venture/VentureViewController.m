// Gizz442@
// VentureViewController.m
//  Venture
//
//  Created by Amy Bearman on 4/11/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "VentureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AFHTTPRequestOperationManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <pthread.h>

@interface VentureViewController()

@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *savedActivities;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeOfTransportation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityType;

@property (weak, nonatomic) IBOutlet UILabel *activityName1;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress1;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification1;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway1;
@property (weak, nonatomic) IBOutlet UIImageView *activityImage1;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating1;
@property (weak, nonatomic) IBOutlet UILabel *iChose1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner1;

@property (weak, nonatomic) IBOutlet UILabel *activityName2;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress2;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification2;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway2;
@property (weak, nonatomic) IBOutlet UIImageView *activityImage2;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating2;
@property (weak, nonatomic) IBOutlet UILabel *iChose2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner2;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) HomeModel *model;
@property (strong, nonatomic) NSArray *activities; // of VentureActivity

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *activityView2;
@property (nonatomic) BOOL activityBool; // True for activityView1

@end

#define FADE_TIME 1.5;

@implementation VentureViewController {
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    
    NSString *activityLat;
    NSString *activityLng;
}

// Lazily intantiate the model
- (HomeModel *)model {
    if (!_model) _model = [[HomeModel alloc] init];
    return _model;
}

// Lazily instantiate the NSArray of VentureActivity's
- (NSArray *)activities {
    if (!_activities) _activities = [[NSArray alloc] init];
    return _activities;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.activityBool = YES;
    self.activityView2.hidden = YES;
    self.activityView.hidden = NO;
    
    [self.spinner1 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner2 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner1 setColor:[UIColor colorWithWhite: 0.70 alpha:1]];
    [self.spinner2 setColor:[UIColor colorWithWhite: 0.70 alpha:1]];
    
    self.spinner1.hidden = NO;
    [self.spinner1 startAnimating];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    self.searchBar.delegate = self;
    
    //Starts up location tracking
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    //Loads first suggestion
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];

    UISwipeGestureRecognizer *swipeRight1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRight)];
    swipeRight1.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeUp1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeUp)];
    swipeUp1.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeRight2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRight)];
    swipeRight2.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeUp2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeUp)];
    swipeUp2.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.activityView addGestureRecognizer:swipeRight1];
    [self.activityView addGestureRecognizer:swipeUp1];
    [self.activityView2 addGestureRecognizer:swipeRight2];
    [self.activityView2 addGestureRecognizer:swipeUp2];
}

-(void)respondToSwipeRight {
    NSLog(@"Swiped right");
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.activityView.layer addAnimation:transition forKey:nil];
    [self.activityView2.layer addAnimation:transition forKey:nil];
    
    if (self.activityBool) {
        self.activityView.hidden = YES;
        self.activityView2.hidden = NO;
        
        //start spinner
        self.spinner1.hidden = NO;
        [self.spinner1 startAnimating];
        
    } else {
        self.activityView2.hidden = YES;
        self.activityView.hidden = NO;
        
        //start spinner
        self.spinner2.hidden = NO;
        [self.spinner2 startAnimating];
        
    }
    
    self.activityBool = !self.activityBool;
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
    
}

-(void)respondToSwipeUp {
    NSString *destAddr;
    if (self.activityBool) {
       destAddr = [self.activityAddress1.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    } else {
       destAddr = [self.activityAddress2.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
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
    }
}

#pragma mark CLLocationManagerDelegate

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
        NSString *lng = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)searchButtonClicked:(id)sender {
    NSString *specifiedLoc = self.searchBar.text;
    [self textFieldShouldReturn:self.searchBar];
    
    [geocoder geocodeAddressString:specifiedLoc
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error) {
                         CLPlacemark *placemark = [placemarks firstObject];
                         currentLocation = placemark.location;
                     } else {
                         NSLog(@"There was a forward geocoding error\n%@",
                               [error localizedDescription]);
                     }
                 }
    ];
    
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
}

-(void)getNewActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling {
    if (self.activityBool) {
        self.activityName1.text = @"";
        self.activityAddress1.text = @"";
        self.activityJustification1.text = @"";
        self.activityDistanceAway1.text = @"";
        self.activityImage1.image = nil;
        self.activityYelpRating1.image = nil;
        self.iChose1.text = @"";
    } else {
        self.activityName2.text = @"";
        self.activityAddress2.text = @"";
        self.activityJustification2.text = @"";
        self.activityDistanceAway2.text = @"";
        self.activityImage2.image = nil;
        self.activityYelpRating2.image = nil;
        self.iChose2.text = @"";
    }
    
    [self.model downloadActivity:indexOfTransport atFeeling:indexOfFeeling withCallback:^(VentureActivity* activity) {
       
        if (self.activityBool) {
            self.activityName1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityName1.alpha = 1;}
                             completion:nil];
            self.activityName1.text = activity.title;
            
            self.activityAddress1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityAddress1.alpha = 1;}
                             completion:nil];
            self.activityAddress1.text = activity.address;
            
            self.activityJustification1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityJustification1.alpha = 1;}
                             completion:nil];
            self.activityJustification1.text = activity.justification;
            
            self.activityImage1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityImage1.alpha = 1;}
                             completion:nil];
            NSString *ImageURL = activity.imageURL;
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
            self.activityImage1.image = [UIImage imageWithData:imageData];
            
            self.activityYelpRating1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityYelpRating1.alpha = 1;}
                             completion:nil];
            NSString *yelpURL = activity.yelpRatingImageURL;
            NSLog(@"%@", yelpURL);
            NSData *imageDataYelp = [NSData dataWithContentsOfURL:[NSURL URLWithString:yelpURL]];
            self.activityYelpRating1.image = [UIImage imageWithData:imageDataYelp];
            
            //Do google maps stuff to get time of travel and distance away
            activityLat = activity.lat;
            activityLng = activity.lng;
            
            CLLocation *loc1 = currentLocation;
            CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[activityLat doubleValue] longitude:[activityLng doubleValue]];
            
            double distance = [loc1 distanceFromLocation:loc2];
            distance /= 1000.0;
            
            self.activityDistanceAway1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityDistanceAway1.alpha = 1;}
                             completion:nil];
            self.activityDistanceAway1.text = [NSString stringWithFormat:@"%f km", distance];
            
             NSLog(@"Activity View 1 loaded");
            
            self.iChose1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.iChose1.alpha = 1;}
                             completion:nil];
            self.iChose1.text = @"I chose this because ... ";
            
        } else {
            self.activityName2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityName2.alpha = 1;}
                             completion:nil];
            self.activityName2.text = activity.title;
            
            self.activityAddress2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityAddress2.alpha = 1;}
                             completion:nil];
            self.activityAddress2.text = activity.address;
            
            self.activityJustification2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityJustification2.alpha = 1;}
                             completion:nil];
            self.activityJustification2.text = activity.justification;
            
            self.activityImage2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityImage2.alpha = 1;}
                             completion:nil];
            NSString *ImageURL = activity.imageURL;
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
            self.activityImage2.image = [UIImage imageWithData:imageData];
            
            self.activityYelpRating2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityYelpRating2.alpha = 1;}
                             completion:nil];
            NSString *yelpURL = activity.yelpRatingImageURL;
            NSLog(@"%@", yelpURL);
            NSData *imageDataYelp = [NSData dataWithContentsOfURL:[NSURL URLWithString:yelpURL]];
            self.activityYelpRating2.image = [UIImage imageWithData:imageDataYelp];
            
            //Do google maps stuff to get time of travel and distance away
            activityLat = activity.lat;
            activityLng = activity.lng;
            
            CLLocation *loc1 = currentLocation;
            CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[activityLat doubleValue] longitude:[activityLng doubleValue]];
            
            double distance = [loc1 distanceFromLocation:loc2];
            distance /= 1000.0;
            
            self.activityDistanceAway2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.activityDistanceAway2.alpha = 1;}
                             completion:nil];
            self.activityDistanceAway2.text = [NSString stringWithFormat:@"%f km", distance];
            
            NSLog(@"Activity View 2 loaded");
            self.iChose2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.iChose2.alpha = 1;}
                             completion:nil];
            self.iChose2.text = @"I chose this because ... ";
        }
        //stop spinner
        if (self.activityBool) {
            [self.spinner1 stopAnimating];
            self.spinner1.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.spinner1.alpha = 1;}
                             completion:nil];
            self.spinner1.hidden = YES;
        } else {
            [self.spinner2 stopAnimating];
            self.spinner2.alpha = 0;
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ self.spinner2.alpha = 1;}
                             completion:nil];
            self.spinner2.hidden = YES;
        }
    }];
}

@end

