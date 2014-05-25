//
//  CreateAdventureTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "CreateAdventureTVC.h"

@interface CreateAdventureTVC () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *categories;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *descriptionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photosCell;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;

@property (strong, nonatomic) UITextField *submitButton;

@end

@implementation CreateAdventureTVC

@synthesize nameCell, descriptionCell, categoryCell, photosCell;
@synthesize nameTextField, descriptionTextField, categoryTextField, submitButton;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Category"];
    self.categories = [[NSArray alloc] initWithObjects:@"Restaurant", @"Park", @"Movie", @"Bar", @"Arts", @"Shopping", nil];

    self.nameTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    self.categoryTextField.delegate = self;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return self.nameCell;
    }
    if (indexPath.row == 1) {
        return self.descriptionCell;
    }
    if (indexPath.row == 2) {
        return self.categoryCell;
    }
    return self.photosCell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == self.categoryTextField) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                      NSLocalizedString(@"Category", @"")
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:
                                      NSLocalizedString(@"Restaurant", @""),
                                      NSLocalizedString(@"Park", @""),
                                      NSLocalizedString(@"Movie", @""),
                                       NSLocalizedString(@"Bar", @""),
                                       NSLocalizedString(@"Arts", @""),
                                       NSLocalizedString(@"Shopping", @""),
                                      nil];
		[actionSheet showInView:self.view];
	
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger)buttonIndex {
	NSLog(@"Index is %i", buttonIndex);
    self.categoryTextField.text = NSLocalizedString([self.categories objectAtIndex:buttonIndex], @"");
}

- (IBAction)uploadPhotosClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                  NSLocalizedString(@"Category", @"")
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"Take Photo", @""),
                                  NSLocalizedString(@"Choose Existing", @""),
                                  nil];
    [actionSheet showInView:self.view];
}

@end





