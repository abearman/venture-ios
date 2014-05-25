//
//  CreateAdventureTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "CreateAdventureTVC.h"
#import "Grid.h"

@interface CreateAdventureTVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableArray *imageViews;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *descriptionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photosCell;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;

@property (weak, nonatomic) IBOutlet UIView *photosView;
@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) UITextField *submitButton;

@end

@implementation CreateAdventureTVC

@synthesize nameCell, descriptionCell, categoryCell, photosCell;
@synthesize nameTextField, descriptionTextField, categoryTextField, submitButton;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    self.categories = [[NSArray alloc] initWithObjects:@"Restaurant", @"Park", @"Movie", @"Bar", @"Arts", @"Shopping", nil];
    [self setUpDelegates];
    [self initializeAllProperties];
    [self setUpGrid];
}

- (void) initializeAllProperties {
    self.imageViews = [[NSMutableArray alloc] init];
    self.grid = [[Grid alloc] init];
}

- (void) setUpDelegates {
    self.nameTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    self.categoryTextField.delegate = self;
    
}

- (void) setUpGrid {
    CGFloat width = self.photosView.frame.size.width;
    CGFloat height = self.photosView.frame.size.height;
    self.grid.size = CGSizeMake(width, height);
    self.grid.cellAspectRatio = 1;
    
    self.grid.minimumNumberOfCells = 0;
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
    if ([actionSheet.title isEqualToString:@"Category"]) {
        self.categoryTextField.text = NSLocalizedString([self.categories objectAtIndex:buttonIndex], @"");
        
    } else if ([actionSheet.title isEqualToString:@"Photos"]) {
        if (buttonIndex == 0) { // Take Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
            
        } else if (buttonIndex == 1) { // Choose Existing
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

- (IBAction)uploadPhotosClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                  NSLocalizedString(@"Photos", @"")
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"Take Photo", @""),
                                  NSLocalizedString(@"Choose Existing", @""),
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.grid.minimumNumberOfCells++;
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:chosenImage];
    [self.imageViews addObject:imageView];
    
    [self resizeExistingPhotos];
    [self addPhoto];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)resizeExistingPhotos {
    int index = 0;
    for (int i = 0; i < self.grid.rowCount; i++) {
        for (int j = 0; j < self.grid.columnCount; j++) {
            if (index >= self.grid.minimumNumberOfCells - 1) break;
            UIImageView *imageView = [self.imageViews objectAtIndex:index];
            CGRect viewRect = [self.grid frameOfCellAtRow:i inColumn:j];
            imageView.frame = viewRect;
            index++;
        }
    }
}

- (void)addPhoto {
    int col = (int)((self.grid.minimumNumberOfCells - 1) % self.grid.columnCount);
    int row = (int)((self.grid.minimumNumberOfCells - 1) / self.grid.columnCount);
    
    int index = (int)(self.grid.minimumNumberOfCells - 1);
    for (int i = row; i < self.grid.rowCount; i++) {
        for (int j = col; j < self.grid.columnCount; j++) {
            if (i > row) j = 0;
            if (index >= self.grid.minimumNumberOfCells) return;
            UIImageView *imageView = [self.imageViews objectAtIndex:index];
            index++;
            CGRect viewRect = [self.grid frameOfCellAtRow:i inColumn:j];
            imageView.frame = viewRect;
            [self.photosView addSubview:imageView];
        }
    }
}


@end





