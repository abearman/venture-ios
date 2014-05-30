//
//  FacebookLoginVC.m
//  Venture
//
//  Created by Amy Bearman on 5/29/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FacebookLoginVC.h"

@interface FacebookLoginVC () <FBLoginViewDelegate>

@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation FacebookLoginVC

- (void) viewDidLoad {
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 200);
    [self.view addSubview:loginView];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.id;
    self.nameLabel.text = user.name;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    NSLog(@"Logging");
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void) setUpFacebook {
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 70);
    [self.view addSubview:loginView];
}


@end
