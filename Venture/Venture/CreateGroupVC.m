//
//  CreateGroupVC.m
//  Venture
//
//  Created by Amy Bearman on 5/30/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "CreateGroupVC.h"
#import <AddressBook/AddressBook.h>

@interface CreateGroupVC ()

@end

@implementation CreateGroupVC

- (void) viewDidLoad {
    [self getAllContacts];
}

- (void) getAllContacts {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBåookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSLog(@"Name:%@ %@", firstName, lastName);

        }
    }
    else {
        // Send an alert telling user to change privacy setting in settings app
    }
}

@end
