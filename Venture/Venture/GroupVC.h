//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>

@interface GroupVC : UIViewController {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *personIcon;

@end