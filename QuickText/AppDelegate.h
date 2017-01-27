//
//  AppDelegate.h
//  QuickText
//
//  Created by Eric Mansfield on 3/10/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultFontSize @"fontSize"
#define kDefaultUseNickname @"userNickname"
#define kDefaultSort @"defaultSort"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)initUserDefaults;

@end
