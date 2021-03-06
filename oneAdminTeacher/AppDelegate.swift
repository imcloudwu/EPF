//
//  AppDelegate.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import CoreData
import Bolts
import Parse

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var centerContainer: MMDrawerController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //SKPaymentQueue.defaultQueue().addTransactionObserver(IAPManager.sharedInstance)
        
        var rootViewController = self.window!.rootViewController
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("StartView") as! UINavigationController
        
        let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SideMenuViewCtrl") as! SideMenuViewCtrl
        
        //var rightViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RightSideViewController") as!  RightSideViewController
        
        //var leftSideNav = UINavigationController(rootViewController: leftViewController)
        //var centerNav = UINavigationController(rootViewController: centerViewController)
        //var rightNav = UINavigationController(rootViewController: rightViewController)
        
        centerContainer = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: leftViewController,rightDrawerViewController:nil)
        
        //centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        //centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView | MMCloseDrawerGestureMode.TapCenterView
        //centerContainer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.TapCenterView
        
        //centerContainer?.showsShadow = false
        centerContainer?.maximumLeftDrawerWidth = 250
        
        window!.rootViewController = centerContainer
        window!.makeKeyAndVisible()
        
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("GWAGeQu6fvO0qhjdI8YbhQMZIwN627v8ns1Q7TID", clientKey: "ApqwNnFiRUj9brEZxiOMwRxUIBCuHYZ2LXhBEsVf")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            //let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            //application.registerForRemoteNotificationTypes(types)
        }

        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        Global.MyDeviceToken = installation.deviceToken
        print(Global.MyDeviceToken)
        installation.badge = 0
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        if application.applicationState == UIApplicationState.Active{
            NotificationService.ExecuteNewMessageDelegate()
        }
    }

    
//    //--------------------------------------
//    // MARK: Push Notifications
//    //--------------------------------------
//    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        let installation = PFInstallation.currentInstallation()
//        installation.setDeviceTokenFromData(deviceToken)
//        installation.saveInBackground()
//        
////        if let dt = installation.deviceToken {
////            //println("DeviceToken：\(installation.deviceToken!)")
////            CurrentUser.notifyService.setup(deviceToken: installation.deviceToken!, accessToken: CurrentUser.accessToken)
////            CurrentUser.notifyService.register()
////        }
//        
//        //使用 1Campus 服務的話，就不需要 Channel 功能。
//        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
//            if succeeded {
//                println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
//            } else {
//                println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
//            }
//        })
//    }
//    
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        if error.code == 3010 {
//            println("Push notifications are not supported in the iOS Simulator.")
//        } else {
//            println("application:didFailToRegisterForRemoteNotificationsWithError: \(error)")
//        }
//    }
//    
//    ///////////////////////////////////////////////////////////
//    // Uncomment this method if you want to use Push Notifications with Background App Refresh
//    ///////////////////////////////////////////////////////////
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        
//        //這個func可以顯示推播訊息
//        PFPush.handlePush(userInfo)
//        
////        if application.applicationState == UIApplicationState.Inactive {
////            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
////        }
////        
////        //App開啟狀態若收到推播進行畫面更新
////        if application.applicationState == UIApplicationState.Active {
////            Global.Callback()
////        }
//    }
//    
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
        
        if Global.LastLoginDateTime == nil{
            Global.LastLoginDateTime = NSDate()
        }
        
        let sec = (Global.LastLoginDateTime.timeIntervalSinceNow) * -1
        
        if sec > 3500{
            
            if let refreshToken = Keychain.load("refreshToken")?.stringValue{
                Keychain.delete("refreshToken")
                
                //println("before : \(Global.AccessToken)")
                
                RenewRefreshToken(refreshToken)
                
                //println("after : \(Global.AccessToken)")
                
                Global.LastLoginDateTime = NSDate()
                
                //Global.HasPrivilege = IsValidated()
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        //SKPaymentQueue.defaultQueue().removeTransactionObserver(IAPManager.sharedInstance)
        
        self.saveContext()
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication){
        PhotoCoreData.Reset()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("oneAdminTeacher", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("oneAdminTeacher.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}

