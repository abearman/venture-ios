//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocationManager;


@interface VentureLocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readonly) NSString *lat;
@property (readonly) NSString *lng;
@property (readonly) NSString *latAcc;
@property (readonly) NSString *lngAcc;
@property (readonly) NSString *altitude;
@property (readonly) NSString *altitudeAcc;

@end