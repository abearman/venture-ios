//
//  RatingViewController.m
//  Venture
//
//  Created by Amy Bearman on 4/15/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "RatingViewController.h"
#import <AFHTTPRequestOperationManager.h>

@interface RatingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ratingTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UIButton *ratingPositiveButton;
@property (weak, nonatomic) IBOutlet UIButton *ratingNegativeButton;
@property (weak, nonatomic) IBOutlet UIButton *ratingSkipButton;

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *retrievedActivityTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"Saved Activity Title"];
    NSString *retrievedActivityImgURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"Saved Activity Image"];
    
    self.ratingTitle.text = [NSString stringWithFormat:@"%@?", retrievedActivityTitle];
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:retrievedActivityImgURL]];
    self.ratingImageView.image = [UIImage imageWithData:imgData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Done With Rating"]) {

    }
}


- (IBAction)ratePositive:(UIButton *)sender {
    NSString *activityID = [[NSUserDefaults standardUserDefaults] objectForKey:@"Saved Activity ID"];
    NSDictionary *parameters = @{@"uid": [[NSNumber alloc] initWithInt:self.userID], @"activityId": activityID, @"rating": [[NSNumber alloc] initWithInt:1]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Rating" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Image"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"Done With Rating" sender:self];
    
    //Loads another suggestion
    /*int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];*/
}

- (IBAction)rateNegative:(UIButton *)sender {
    /*NSDictionary *parameters = @{@"uid": [[NSNumber alloc] initWithInt:userID], @"activityId": self.savedActivity.ID, @"rating": [[NSNumber alloc] initWithInt:0]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Rating" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    self.ratingView.hidden = YES;
    self.activityView.hidden = NO;
    [imageView removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Image"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Loads another suggestion
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];*/
}

- (IBAction)skipRating:(UIButton *)sender {
    /*self.ratingView.hidden = YES;
    self.activityView.hidden = NO;
    [imageView removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Image"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Saved Activity Title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Loads another suggestion
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];*/
}

@end
