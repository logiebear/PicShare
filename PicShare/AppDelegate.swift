//
//  AppDelegate.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

let customBackendParseAppId = "QxhPBK9OoKFLvvWK2PKY"
let customBackendParseClientKey = "IFG5gB7cn5unrLY12aQM"
let customBackendParseEndPoint = "http://picshare-parse.herokuapp.com/parse"

let parseAppId = "kTUGnKfb8P2iWFLsrAKebZN9NU3DOcea0wYD3jlG"
let parseClientKey = "rkcMIpTeYqSAvlruQHfdmlvfsbTrwUYFTbRnmGW7"

let useCustomParseBackend = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        // Parse.enableLocalDatastore()
        
        // Initialize Parse.
        if useCustomParseBackend {
            Parse.setApplicationId(parseAppId, clientKey: parseClientKey)
        } else {
            let config = ParseClientConfiguration(block: { ParseMutableClientConfiguration -> Void in
                ParseMutableClientConfiguration.applicationId = customBackendParseAppId;
                ParseMutableClientConfiguration.clientKey = customBackendParseClientKey;
                ParseMutableClientConfiguration.server = customBackendParseEndPoint;
            })
            Parse.initializeWithConfiguration(config)
        }
        
        // [Optional] Track statistics around application opens.
        // PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //Register PFUser subclass
        User.registerSubclass()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

