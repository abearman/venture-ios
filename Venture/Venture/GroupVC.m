//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserveGroupVCd.
//

#import "GroupVC.h"
#import "GroupsListTVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import <CoreData/CoreData.h>

@interface GroupVC() <FBFriendPickerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) UIManagedDocument *document;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UIView *addMembersView;
@property (weak, nonatomic) IBOutlet UIButton *addMembersButton;

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (strong, nonatomic) NSMutableArray *contacts;

@end

@implementation GroupVC

@synthesize contacts;
@synthesize fetchedResultsController, context;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpGestureRecognizers];
    [self setUpNavigationBar];
    [self initProperties];
    [self setUpCoreData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"CreateGroup"
                                               object:nil];
    [self setUpAddMembersView];
}

- (void) setUpCoreData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"Venture Data";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"couldn’t open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentIsReady];
              if (!success) NSLog(@"couldn’t create document at %@", url);
          }];
    }
}

- (void) documentIsReady {
    if (self.document.documentState == UIDocumentStateNormal) {
        self.context = self.document.managedObjectContext;
    }
}

- (void) initProperties {
    self.contacts = [[NSMutableArray alloc] init];
}

- (IBAction)addMembers:(UIButton *)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark People Picker

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
    for (NSString *contact in self.contacts) {
        NSLog(@"%@", contact);
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    
    self.firstName.text = name;
    [self.contacts addObject:name];
    
    NSManagedObject *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    [friend setValue:name forKey:@"name"];
    [friend setValue:imageData forKey:@"image"];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved!");
    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    return YES;
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (void) setUpAddMembersView {
    // border radius
    [self.addMembersView.layer setCornerRadius:20.0f];
    [self.addMembersButton.layer setCornerRadius:8.0f];
    
    // border
    [self.addMembersView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.addMembersView.layer setBorderWidth:0.5f];
}

- (void) receiveTestNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"CreateGroup"]) {
        NSLog (@"Successfully received the test notification!");
        
        // Unroll the groups list view
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             [self.groupName becomeFirstResponder];
                         }];
    }
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
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