//
//  PersonViewController.h
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <ContactsUI/ContactsUI.h>

@interface PersonViewController : UITableViewController<NSFetchedResultsControllerDelegate, CNContactPickerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)addContactTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end
