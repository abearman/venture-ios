//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserveGroupVCd.
//

#import "GroupVC.h"
#import "GroupsListTVC.h"

@interface GroupVC()

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@end

@implementation GroupVC

- (void) viewDidLoad {
    [self setUpGestureRecognizers];
    [self setUpNavigationBar];
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lobster" size:40];
    label.textColor = [UIColor whiteColor];
    label.text = @"Venture";
    label.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = label;
}

- (void) setUpGestureRecognizers {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    
    [pan requireGestureRecognizerToFail:swipeRight];
    [pan requireGestureRecognizerToFail:swipeLeft];
    
    [self.centerView addGestureRecognizer:swipeRight];
    [self.centerView addGestureRecognizer:swipeLeft];
    [self.centerView addGestureRecognizer:pan];
}

- (void) panDetected:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat xTranslate = gesture.view.center.x + translation.x;
    gesture.view.center = CGPointMake(xTranslate, gesture.view.center.y);
    [gesture setTranslation:CGPointMake(0, 0) inView: gesture.view];
    
    if (self.centerView.frame.origin.x < 0.0) {
        self.leftView.hidden = YES;
        self.rightView.hidden = NO;
    } else {
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void) swipeRight:(UISwipeGestureRecognizer *)gesture {
    CGFloat x = self.centerView.frame.origin.x;
    if (x == 0.0) {
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    } else if (x == -240.0) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void) swipeLeft:(UISwipeGestureRecognizer *)gesture {
    CGFloat x = self.centerView.frame.origin.x;
    if (x == 240.0) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    } else if (x == 0.0) {
        self.leftView.hidden = YES;
        self.rightView.hidden = NO;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(-240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

@end