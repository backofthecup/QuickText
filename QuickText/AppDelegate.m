//
//  AppDelegate.m
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataDao.h"


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    // init user defaults
    [self initUserDefaults];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)initUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kDefaultFontSize] < 6) {
        [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:kDefaultFontSize];
    }
    
    static NSString *key = @"defaultMessagesLoaded";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        // Path to the plist (in the application bundle)
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Messages" ofType:@"plist"];
        
        // Build the array from the plist  
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSMutableArray *messages = [dict objectForKey:@"Root"];
        for (NSString *message in messages) {
            [[CoreDataDao sharedDao] createMessageWithBody:message];
        }
        
        // use nicknames
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultUseNickname];

        // only do once
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
