//
//  AppDelegate.swift
//  TextQuick
//
//  Created by Eric Mansfield on 12/27/17.
//  Copyright © 2017 AppsOnTheSide, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let kDefaultFontSize = "fontSize"
    static let kDefaultUseNickname = "userNickname"
    static let kDefaultSort = "defaultSort"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.initUserDefaults()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func initUserDefaults() {
        if UserDefaults.standard.integer(forKey: AppDelegate.kDefaultFontSize) < 6 {
            UserDefaults.standard.set(16, forKey: AppDelegate.kDefaultFontSize)
        }
        let key = "defaultMessagesLoaded"
        if !UserDefaults.standard.bool(forKey: key) {
            // Path to the plist (in the application bundle)
            guard let path = Bundle.main.path(forResource: "Messages", ofType: "plist") else {
                return
            }
            
            // Build the array from the plist
            
            let dict = NSDictionary(contentsOfFile: path) as! [String: [String]]
            let messages = dict["Root"]!
            for message in messages {
                CoreDataDao.shared().createMessage(withBody: message)
            }
            // use nicknames
            UserDefaults.standard.set(true, forKey: AppDelegate.kDefaultUseNickname)
            // only do once
            UserDefaults.standard.set(true, forKey: key)
        }
        UserDefaults.standard.synchronize()
    }

}
