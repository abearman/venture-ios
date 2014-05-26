//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "GroupVC.h"

@interface GroupVC()
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@end

@implementation GroupVC

- (void) viewDidLoad {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.centerView addGestureRecognizer:swipeRight];
    [self.centerView addGestureRecognizer:swipeLeft];
}

- (void) swipeRight:(UISwipeGestureRecognizer *)gesture {
    CGFloat x = self.centerView.frame.origin.x;
    if (x == 0.0) {
        self.leftView.hidden = NO;
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
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(-240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

/*- (void) swipeDetected: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"X: %f", self.centerView.frame.origin.x);
    
    CGFloat x = self.centerView.frame.origin.x;
    
    if (x == 0) {
        if (xVelocity >= 500.0) {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.centerView.frame = CGRectMake(240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                             }
                             completion:nil];
        } else if (xVelocity <= -500.0) {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.centerView.frame = CGRectMake(-240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                             }
                             completion:nil];
        }
    } else if (x == 240.0) {
        if (xVelocity >= 500.0) {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.centerView.frame = CGRectMake(240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                             }
                             completion:nil];
        } else if (xVelocity <= -500.0) {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.centerView.frame = CGRectMake(0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                             }
                             completion:nil];
        }
    }
    
    /*else if (xVelocity <= -500.0 && x <= 160.0 && x >= -90.0) {
        self.leftView.hidden = YES;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             gesture.view.center = CGPointMake(-90.0, gesture.view.center.y);
                         }
                         completion:nil];
    }*/
    
    // Displaying left view
    
    /*CGFloat xTranslate = gesture.view.center.x + translation.x;
    if (xTranslate >= 160.0 && xTranslate <= 420.0) {
        self.leftView.hidden = NO;
        gesture.view.center = CGPointMake(xTranslate, gesture.view.center.y);
    }
    [gesture setTranslation:CGPointMake(0, 0) inView: gesture.view];*/
    
    // Displaying right view
    /* else if (xTranslate <= 160.0 && xTranslate >= -90.0) {
        self.leftView.hidden = YES;
        gesture.view.center = CGPointMake(xTranslate, gesture.view.center.y);
    }
}*/

@end