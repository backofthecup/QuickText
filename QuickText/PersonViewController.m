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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)addContactTapped:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"key == 'phoneNumbers' OR key == 'emailAddresses' "];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    NSLog(@"...didCancel...");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
//    
//    NSLog(@"...shouldContinueAfterSelectingPerson....");
//    
//    return YES;
//}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    NSLog(@"...shouldContinueAfterSelectingPerson:property:identifier..%@ %i %i", person, property, identifier);

    if (property == kABPersonPhoneProperty || property == kABPersonEmailProperty) {
        
        // get the name and number selected
        NSString *first = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *last = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSString *company = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty));
        
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
            NSString *nickname = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonNicknameProperty));
            NSLog(@"%@....", nickname);
            if (nickname != nil) {
                NSLog(@"Using nickname instead");
                nameString = [NSString stringWithFormat:@"%@", nickname];
            }
        }
        
        ABMultiValueRef multi = ABRecordCopyValue(person, property);
        NSString *phoneString = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
        CFRelease(multi);
        
        // check for duplicates
        NSArray *array = [[CoreDataDao sharedDao] findContactWithPhone:phoneString];
        if ([array count]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"A contact already exists with number." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];
            
            return;
        }
        
        // insert contact into core data
        [[CoreDataDao sharedDao] createContactWithName:nameString phone:phoneString];
        
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
//    
//    if (property == kABPersonPhoneProperty || property == kABPersonEmailProperty) {
//        NSLog(@"...shouldContinueAfterSelectingPerson:property:identifier..%@ %i %i", person, property, identifier);
//
//        // get the name and number selected
//        NSString *first = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//        NSString *last = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
//        NSString *company = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty));
// 
//        NSString *nameString = nil;
//        if (first == nil) {
//            if (last == nil) {
//                if (company == nil) {
//                    nameString = @"";
//                }
//                else {
//                    nameString = company;
//                }
//            }
//            else {
//                nameString = last;
//            }
//        }
//        else if (last == nil) {
//            nameString = first;
//        }
//        else {
//            nameString = [NSString stringWithFormat:@"%@ %@", first, last];
//        }
//        
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDefaultUseNickname]) {
//            NSString *nickname = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonNicknameProperty));
//            NSLog(@"%@....", nickname);
//            if (nickname != nil) {
//                NSLog(@"Using nickname instead");
//                nameString = [NSString stringWithFormat:@"%@", nickname];
//            }
//        }
//        
//        ABMultiValueRef multi = ABRecordCopyValue(person, property);
//        NSString *phoneString = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, identifier));
//        CFRelease(multi);
//
//        // check for duplicates
//        NSArray *array = [[CoreDataDao sharedDao] findContactWithPhone:phoneString];
//        if ([array count]) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QuickMessage" message:@"A contact already exists with number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            
//            return NO;
//        }
//        
//        // insert contact into core data
//        
//        [[CoreDataDao sharedDao] createContactWithName:nameString phone:phoneString];
//        
//                
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    
//    return NO;
//}

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

