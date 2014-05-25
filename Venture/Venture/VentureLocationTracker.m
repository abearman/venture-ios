//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "VentureLocationTracker.h"


@implementation VentureLocationTracker {
    CLLocation *currentLocation;
}

#pragma mark Constructor

-(id)init {
    self = [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark LocationGetters

-(NSString*)getLat {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.coordinate.latitude];
}

-(NSString*)getLng {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.coordinate.longitude];
}

-(NSString*)getLatAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.verticalAccuracy];
}

-(NSString*)getLngAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.horizontalAccuracy];
}

-(NSString*)getAltitude {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.altitude];
}

-(NSString*)getAltitudeAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",currentLocation.verticalAccuracy];
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
}

@end