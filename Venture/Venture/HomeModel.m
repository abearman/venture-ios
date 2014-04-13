//
//  HomeModel.m
//  Venture
//
//  Created by Amy Bearman on 4/12/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

//post request with lat/lng

#import "HomeModel.h"
#import "VentureActivity.h"
#import <AFHTTPRequestOperationManager.h>

@interface HomeModel() {
    NSMutableData *_downloadedData;
}
@end

@implementation HomeModel

-(void)downloadActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling withUser:(int)userID withCallback:(void (^)(VentureActivity *))callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *modeOfTransport;
    if (indexOfTransport == 0) {
        modeOfTransport = @"walking";
    } else if (indexOfTransport == 1) {
        modeOfTransport = @"bicycling";
    } else if (indexOfTransport == 2) {
        modeOfTransport = @"driving";
    } else if (indexOfTransport == 3) {
        modeOfTransport = @"transit";
    }
    
    NSString *feeling;
    if (indexOfFeeling == 0) {
        feeling = @"hungry";
    } else if (indexOfFeeling == 1) {
        feeling = @"adventurous";
    } else if (indexOfFeeling == 2) {
        feeling = @"bored";
    }
    
    NSDictionary *parameters = @{@"lat": @"37.43777", @"lng": @"-122.1374", @"uid": @"3", @"transport": modeOfTransport, @"feeling": feeling, @"uid": [[NSNumber alloc] initWithInt:userID] };
    
    //transport, feeling
    //walking bicycling transit driving
    //hungry adventurous bored
    
    //yelp_rating (numeric)
    //yelp_rating_img_url --small --large
    //yelp_thumbnail (image)
    
    VentureActivity *activity = [[VentureActivity alloc] init];
    
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Brain" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = (NSDictionary *)(responseObject);
        NSDictionary *suggestion = [dict objectForKey:@"suggestion"];
        NSString *justification = [dict objectForKey:@"reason"];
        
        NSString *ID = [suggestion objectForKey:@"id"];
        NSString *title = [suggestion objectForKey:@"title"];
        NSString *address = [suggestion objectForKey:@"address"];
        NSString *lat = [suggestion objectForKey:@"lat"];
        NSString *lng = [suggestion objectForKey:@"lng"];
        NSString *yelpImageURL = [suggestion objectForKey:@"yelp_rating_img_url"];
        NSString *imageURL = [suggestion objectForKey:@"yelp_thumbnail"];
        
        activity.ID = ID;
        activity.title = title;
        activity.address = address;
        activity.justification = justification;
        activity.lat = lat;
        activity.lng = lng;
        activity.yelpRatingImageURL = yelpImageURL;
        activity.imageURL = imageURL;
        
        callback(activity);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

};

@end



