//
//  EditMessageViewController.h
//  QuickText
//
//  Created by Eric Mansfield on 3/11/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickMessage.h"

@interface EditMessageViewController : UITableViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic,strong) QuickMessage *message;

@property (strong, nonatomic) IBOutlet UITableViewCell *tableCell;

- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
