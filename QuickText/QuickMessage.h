//
//  QuickMessage.h
//  QuickText
//
//  Created by Eric Mansfield on 3/12/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QuickMessage : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * timestamp;

@end
