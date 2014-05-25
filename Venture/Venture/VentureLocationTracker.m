//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "VentureLocationTracker.h"


@implementation VentureLocationTracker {
    CLGeocoder *_geocoder;
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
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

#pragma mark LocationGetters

-(NSString*)lat {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.coordinate.latitude];
}

-(NSString*)lng {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.coordinate.longitude];
}

-(NSString*)latAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.verticalAccuracy];
}

-(NSString*)lngAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.horizontalAccuracy];
}

-(NSString*)altitude {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.altitude];
}

-(NSString*)altitudeAcc {
    return [[NSString alloc] initWithFormat:@"%+.6f",_currentLocation.verticalAccuracy];
}

#pragma mark Location override

-(void)setLocationToAddress:(NSString *)location {
    [_geocoder geocodeAddressString:location
                      completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            [_locationManager stopUpdatingLocation];
            CLPlacemark *placemark = [placemarks firstObject];
            _currentLocation = placemark.location;
        } else {
            NSLog(@"There was a forward geocoding error\n%@",
                    [error localizedDescription]);
            [self clearAddress];
        }
    }];
}

-(void)clearAddress {
    [_locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    _currentLocation = newLocation;
}

@end