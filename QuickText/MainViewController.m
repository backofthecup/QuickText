//
//  MainViewController.m
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import "MainViewController.h"
#import "CoreDataDao.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize messagePickerView = _messagePickerView;
@synthesize personPickerView = _personPickerView;
@synthesize sendMessageButton = _sendMessageButton;
@synthesize messageFetchedResultsController = __messageFetchedResultsController;
@synthesize contactFetchedResultsController = __contactFetchedResultsController;

# pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // this will cause a redraw
    self.personPickerView.delegate = self;
    self.messagePickerView.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger rows = 1;
    
    if (pickerView == self.messagePickerView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.messageFetchedResultsController sections] objectAtIndex:0];
        rows = [sectionInfo numberOfObjects];
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.contactFetchedResultsController sections] objectAtIndex:0];
        rows = [sectionInfo numberOfObjects];
        
    }

    return rows;
}

#pragma mark - UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width - 35, pickerView.frame.size.height - 10)];
        
        NSInteger size = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultFontSize];
        label.font = [UIFont systemFontOfSize:size];
        label.textColor = [UIColor blackColor];
        view = label;
    }
    
    if (pickerView == self.messagePickerView) {
        QuickMessage *message = [self.messageFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        label.text = message.body;
        
    }
    else {
        QuickContact *contact = [self.contactFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        NSLog(@"...contact %@ %@", contact.name, contact.phone);
        label.text = [NSString stringWithFormat:@"%@ %@", contact.name , contact.phone];
        
        view = label;
        
    }

    return view;
}


#pragma mark - MFMessageComposer
- (IBAction)composeTapped:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        
        // who
        if ([self.personPickerView numberOfRowsInComponent:0] > 0) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:[self.personPickerView selectedRowInComponent:0] inSection:0];
            QuickContact *contact = [self.contactFetchedResultsController objectAtIndexPath:index];
            controller.recipients = [NSArray arrayWithObject:contact.phone];
        }
        
        // message
        if ([self.messagePickerView numberOfRowsInComponent:0] > 0) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:[self.messagePickerView selectedRowInComponent:0] inSection:0];
            QuickMessage *message = [self.messageFetchedResultsController objectAtIndexPath:index];
            controller.body = message.body;
        }
        
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"This device cannot send Messages." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    NSLog(@"composer finished....");
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)messageFetchedResultsController
{
    if (__messageFetchedResultsController != nil) {
        return __messageFetchedResultsController;
    }
    __messageFetchedResultsController = [[CoreDataDao sharedDao] fetchedResultsController:@"QuickMessage" sortString:@"body" delegate:self];
    
    
    return __messageFetchedResultsController;
}    

- (NSFetchedResultsController *)contactFetchedResultsController
{
    if (__contactFetchedResultsController != nil) {
        return __contactFetchedResultsController;
    }
    __contactFetchedResultsController = [[CoreDataDao sharedDao] fetchedResultsController:@"QuickContact" sortString:@"name" delegate:self];
    
    return __contactFetchedResultsController;
}    


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (controller == self.contactFetchedResultsController) {
        [self.personPickerView reloadAllComponents];
    }
    else {
        [self.messagePickerView reloadAllComponents];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{

    if (controller == self.contactFetchedResultsController) {
        [self.personPickerView reloadAllComponents];
    }
    else {
        [self.messagePickerView reloadAllComponents];
    }
}




@end
