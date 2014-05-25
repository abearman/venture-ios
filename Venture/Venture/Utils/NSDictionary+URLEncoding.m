//
// Created by Keenon Werling on 5/24/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "NSDictionary+URLEncoding.h"


@implementation NSDictionary (URLEncoding)

-(NSString *)urlEncoded {
    NSMutableString *encoded = [[NSMutableString alloc] init];
    for (NSString *key in [self keyEnumerator]) {
        NSString *escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *escapedValue = [[self objectForKey: key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [encoded appendFormat:(encoded.length > 0 ? @"&%@=%@" : @"%@=%@"), escapedKey, escapedValue];
    }
    return encoded;
}

@end