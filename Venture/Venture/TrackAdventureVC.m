//
//  SubmitAdventureVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "TrackAdventureVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "CreateAdventureTVC.h"

#define METERS_PER_MILE 1609.344
#define DURATION_LONG_PRESS 0.5

@interface TrackAdventureVC () <CLLocationManagerDelegate, MKMapViewDelegate>

@end

@implementation TrackAdventureVC

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    [self setUpGestureRecognizersForMap];
    
    [self.mapView.userLocation addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void) viewWillAppear:(BOOL)animated {
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 40.740384;
    coordinate.longitude = -73.991146;
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinate;
    [self.mapView addAnnotation:point];
}

- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    @try {
        [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    }@catch(id anException) {
        // Do nothing
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([self.mapView showsUserLocation]) {
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 1; // Change these values to change the zoom
        span.longitudeDelta = 1;
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
    }
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

- (void) setUpGestureRecognizersForMap {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = DURATION_LONG_PRESS; //user needs to press for half a second
    [self.mapView addGestureRecognizer:lpgr];
}

- (void) handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annotation];
    self.selectedAnnotation = annotation;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"Selected annotation!");
    self.selectedAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"Selected Annotation" sender:self.mapView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Selected Annotation"]) {
        CreateAdventureTVC *catvc = segue.destinationViewController;
        catvc.annotation = self.selectedAnnotation;
    }
}

@end




