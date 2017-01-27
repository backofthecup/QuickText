//
//  PersonViewController.h
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PersonViewController : UITableViewController<NSFetchedResultsControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)addContactTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end
