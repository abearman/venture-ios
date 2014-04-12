//
//  GetActivities.h
//  Venture
//
//  Created by Amy Bearman on 4/12/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VentureActivity : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double distanceAway;
@property (nonatomic) double timeAway;
@property (nonatomic, strong) NSString *yelpRatingURL;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *justification;

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

@end
