//
//  MessageViewController.h
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MessageViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)doneTapped:(id)sender;

@end
