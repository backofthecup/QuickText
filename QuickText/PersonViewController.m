//
//  PersonViewController.m
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import "PersonViewController.h"
#import "CoreDataDao.h"
#import "AppDelegate.h"

@interface PersonViewController () {
    BOOL presentOnInit;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation PersonViewController

@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.fetchedResultsController.fetchedObjects count] < 1) {
        presentOnInit = YES;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (presentOnInit) {
        presentOnInit = NO;
//        [self addContactTapped:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *title = @"";
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] > 0) {
        title = @"Swipe from right to left to delete a contact.";
    }

    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Tap + to add contacts from address book";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@".....deleting object from fetched controller....");
        NSManagedObjectContext *context = [CoreDataDao sharedDao].managedObjectContext;
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }  
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)presentContactPicker {
    CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
    controller.delegate = self;
    controller.displayedPropertyKeys = @[CNContactEmailAddressesKey, CNContactPhoneNumbersKey];
    controller.predicateForEnablingContact = [NSPredicate predicateWithFormat: @"emailAddresses.@count > 0 OR phoneNumbers.@count > 0"];
    [self presentViewController:controller animated:YES completion:nil];
 
}

- (IBAction)addContactTapped:(id)sender {
    CNContactStore *store = [[CNContactStore alloc] init];
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self presentContactPicker];
            }
        }];
        
    }
    else if (status == CNAuthorizationStatusAuthorized) {
        [self presentContactPicker];
    }
    else if (status == CNAuthorizationStatusDenied) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"Please allow access to Contacts for this app in Settings > Texting 1-2-3" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
        [controller addAction:settings];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CNContactPickerViewDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    NSLog(@"Contact property selected %@", contactProperty);
    
    CNContact *contact = contactProperty.contact;
    NSString *first = contact.givenName;
    NSString *last = contact.familyName;
    NSString *company = contact.organizationName;
    
    NSString *nameString = nil;
    if (first == nil) {
        if (last == nil) {
            if (company == nil) {
                nameString = @"";
            }
            else {
                nameString = company;
            }
        }
        else {
            nameString = last;
        }
    }
    else if (last == nil) {
        nameString = first;
    }
    else {
        nameString = [NSString stringWithFormat:@"%@ %@", first, last];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultUseNickname]) {
        NSString *nickname = contact.nickname;
        NSLog(@"%@....", nickname);
        if (nickname != nil && nickname.length > 0) {
            NSLog(@"Using nickname instead");
            nameString = [NSString stringWithFormat:@"%@", nickname];
        }
    }
    
    NSString *phoneString = @"";
    if ([contactProperty.key isEqualToString:CNContactPhoneNumbersKey]) {
        CNPhoneNumber *phone = contactProperty.value;
        phoneString = phone.stringValue;
    }
    else if ([contactProperty.key isEqualToString:CNContactEmailAddressesKey]) {
        phoneString = contactProperty.value;
    }
    
    if (phoneString.length < 1) {
        return;
    }
    
    // check for duplicates
    NSArray *array = [[CoreDataDao sharedDao] findContactWithPhone:phoneString];
    if (array.count > 0) {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"A contact already exists with number." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];
        }];
        
        return;
    }
    
    // insert contact into core data
    [[CoreDataDao sharedDao] createContactWithName:nameString phone:phoneString];

}


#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    __fetchedResultsController = [[CoreDataDao sharedDao] fetchedResultsController:@"QuickContact" sortString:@"name" delegate:self];
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"NSFetchedResultsChangeDelete.......");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    QuickContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.phone; 
}

@end

