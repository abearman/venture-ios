//
//  HomeModel.h
//  Venture
//
//  Created by Amy Bearman on 4/12/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VentureActivity.h"

@protocol HomeModelProtocol <NSObject>

@end

@interface HomeModel : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<HomeModelProtocol> delegate;

-(void)downloadActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling withUser:(int)userID withCallback:(void (^)(VentureActivity *))callback;

@end