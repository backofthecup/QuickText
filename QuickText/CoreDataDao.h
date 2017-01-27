//
//  CoreDataDao.h
//  BackToMyCar
//
//  Created by Eric Mansfield on 5/24/10.
//  Copyright 2010 AppsOnTheSide, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "QuickMessage.h"
#import "QuickContact.h"



@interface CoreDataDao : NSObject {
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;	    
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataDao *)sharedDao;

- (NSString *)applicationDocumentsDirectory;

- (NSFetchedResultsController *)fetchedResultsController:(NSString *)entityName sortString:(NSString *)sortString delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

- (QuickMessage *)createMessageWithBody:(NSString *)body;

- (QuickContact *)createContactWithName:(NSString *)name phone:(NSString *)phone;

- (NSArray *)findContactWithPhone:(NSString *)phone;

- (NSManagedObject *)createManagedObject:(NSString *)entity;

- (BOOL) save;
- (void) rollback;


@end
