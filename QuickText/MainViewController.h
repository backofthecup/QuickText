//
//  MainViewController.h
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>



@interface MainViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *messagePickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *personPickerView;

@property (strong, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (strong, nonatomic) NSFetchedResultsController *messageFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *contactFetchedResultsController;

- (IBAction)composeTapped:(id)sender;

@end
