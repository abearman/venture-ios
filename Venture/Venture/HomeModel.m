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

-(void)downloadActivity:(void (^)(VentureActivity *))callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"lat": @"37.43777", @"lng": @"-122.1374"};
   
    VentureActivity *activity = [[VentureActivity alloc] init];
    
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Brain" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = (NSDictionary *)(responseObject);
        NSDictionary *suggestion = [dict objectForKey:@"Suggestion"];
        
        NSString *title = [suggestion objectForKey:@"title"];
        NSString *address = [suggestion objectForKey:@"address"];
        NSString *justification = [dict objectForKey:@"Reason"];
        
        activity.title = title;
        activity.address = address;
        activity.justification = justification;
        
        callback(activity);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

};

@end



