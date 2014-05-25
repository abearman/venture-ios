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
#import "VentureLocationTracker.h"
#import "VentureServerLayer.h"

@interface SuggestionVC() <UISearchBarDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

/* Model */
@property (nonatomic) NSInteger modeOfTransportation;
@property (nonatomic) NSInteger activityType;
@property (nonatomic) VentureLocationTracker *locationTracker;
@property (nonatomic) VentureServerLayer *serverLayer;

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *activityView;

@property (weak, nonatomic) IBOutlet UILabel *activityName;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification;
@property (weak, nonatomic) IBOutlet UIImageView *ventureBotImageView;

@end

@implementation SuggestionVC

- (void) viewDidLoad {
    [super viewDidLoad];
    self.activityView.userInteractionEnabled = YES;

    self.locationTracker = [[VentureLocationTracker alloc] init];
    self.serverLayer = [[VentureServerLayer alloc] initWithLocationTracker:self.locationTracker];

    self.modeOfTransportation = self.activityType = 0;

    [self setUpNavigationBar];
    [self setUpSearchBar];
    [self setUpGestureRecognizers];

    [self getNewActivity:self.modeOfTransportation atFeeling:self.activityType];
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

    [self.locationTracker setLocationToAddress:specifiedLoc];

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

-(void)getNewActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling {
    [self.spinner startAnimating];
    [self.serverLayer getNewAdventureSuggestion:^(NSDictionary *suggestion) {
        [self.spinner stopAnimating];

        self.activityName.text = [suggestion objectForKey:@"title"];
        self.activityAddress.text = [suggestion objectForKey:@"address"];
        self.activityJustification.text = @"... todo/remove";

        // Pull down the image async


        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[suggestion valueForKeyPath:@"metadata/urbanspoon_images"] objectAtIndex:0]]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([self.activityName.text isEqualToString:[suggestion objectForKey:@"title"]]) {
                    NSData *imageData = [NSData dataWithContentsOfURL:location];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = [UIImage imageWithData:imageData];
                    });
                }
            }
        }];

        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[[suggestion objectForKey:@"lat"] doubleValue] longitude:[[suggestion objectForKey:@"lng"] doubleValue]];

        double distance = [self.locationTracker.currentLocation distanceFromLocation:loc2];
        distance /= 1000.0;
        self.activityDistanceAway.text = [NSString stringWithFormat:@"%f km", distance];
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






