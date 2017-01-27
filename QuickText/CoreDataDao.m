//
//  CoreDataDao.m
//  BackToMyCar
//
//  Created by Eric Mansfield on 5/24/10.
//  Copyright 2010 AppsOnTheSide, LLC. All rights reserved.
//

#import "CoreDataDao.h"

#define kSqliteFileName @"quicktext.1.sqlite"

@implementation CoreDataDao

static CoreDataDao *singleton = nil;

+(CoreDataDao *)sharedDao;
{
	@synchronized([CoreDataDao class])
	{
		if (!singleton)
			[[self alloc] init];
		
		return singleton;
	}
	
	return nil;
}

+(id)alloc
{
	@synchronized([CoreDataDao class])
	{
		NSAssert(singleton == nil, @"Attempted to allocate a second instance of a singleton.");
		singleton = [super alloc];
		return singleton;
	}
	
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
	}
	
	return self;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kSqliteFileName]];
	NSLog(@"%@", [storeUrl description]);
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"CORE DATA ERROR: Unresolved error %@, %@", error, [error userInfo]);
        
        abort();
    }
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (NSArray *)executeFetchRequest:(NSFetchRequest *)request {
	NSError *error = nil;
	NSArray *list = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"........Core Data error occurred %@", [error localizedDescription]);
	}
	
	
	return list;
}

- (NSManagedObject *)createManagedObject:(NSString *)entity {
	NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self.managedObjectContext];
	
	return object;

}

- (BOOL)save {
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		if (error) {
			NSLog(@"ERROR.......Core Data error occurred %@ %@", [error userInfo], [error localizedDescription]);
			return NO;
		}
	}
	else {
		NSLog(@"...CoreDataDao save was successful....");
	}

	return YES;
}

- (void)rollback {
	[self.managedObjectContext rollback];
}


#pragma mark - CRUD
- (NSFetchedResultsController *)fetchedResultsController:(NSString *)entityName sortString:(NSString *)sortString delegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortString ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"%@-cache", entityName]];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    fetchedResultsController.delegate = delegate;
    
    return fetchedResultsController;

    
}

- (QuickMessage *)createMessageWithBody:(NSString *)body {
    QuickMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"QuickMessage" inManagedObjectContext:self.managedObjectContext];
                        
    message.body = body;
    message.timestamp = [NSDate date];
    
    [self save];
    
    return message;
}

- (QuickContact *)createContactWithName:(NSString *)name phone:(NSString *)phone {
    QuickContact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"QuickContact" inManagedObjectContext:self.managedObjectContext];
    
    contact.name = name;
    contact.phone = phone;
    contact.timestamp = [NSDate date];
    
    [self save];
    
    return contact;
}

- (NSArray *)findContactWithPhone:(NSString *)phone {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"QuickContact"];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phone == %@", phone];
	[request setPredicate:predicate];
    
    return [self executeFetchRequest:request];
    
}


										

@end
