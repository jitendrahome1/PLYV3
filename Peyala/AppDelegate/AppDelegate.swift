//
//  AppDelegate.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Varriable Declaration
    var window: UIWindow?
    
    //MARK: - Application Life Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Timberjack.register()
        GMSServices.provideAPIKey("AIzaSyDAHiODmRMtFhuEe6KM5EEtU7CkthafiDk")
        GMSPlacesClient.provideAPIKey("AIzaSyDAHiODmRMtFhuEe6KM5EEtU7CkthafiDk")
        registerForPushNotifications(application)
        configureGAnalytics()
        
        //Crittercism tasks
        Crittercism.enable(withAppID: CRITTERCISM_APP_ID)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().barTintColor = UIColorRGB(11, g: 140, b: 60)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        SET_NOTIFICATION_BADGE("\(application.applicationIconBadgeNumber > 0 ? "\(application.applicationIconBadgeNumber)" : "")")
        appInitializers()
        PYLAPIManager.sharedManager.startMonitoring()
        let frontViewController = otherStoryboard.instantiateViewController(withIdentifier: (String(describing: PYLCustomSplashViewController.self))) as! PYLCustomSplashViewController
        self.window?.rootViewController = frontViewController
        PYLGlobals.globals.NotificationBannerTapped = false
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
        
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
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //        UIApplication.sharedApplication().applicationIconBadgeNumber = 0 //soumen
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SET_NOTIFICATION_BADGE("\(application.applicationIconBadgeNumber > 0 ? "\(application.applicationIconBadgeNumber)" : "")")
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_BADGE_UPDATE), object: nil)
        PYLGlobals.globals.NotificationBannerTapped = false
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    //MARK: - Register Device Token For Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        PYLHelper.helper.deviceID = deviceTokenString
        debugPrint("deviceTokenString - \(deviceTokenString)")
    }
    
    //MARK: - Fail to Register Device Token For Push Notification
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    //MARK: - Receive Push Notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        if (application.applicationState == .active) {
            
            //app is in foreground, now just update the counter of the notification icon
            /*
             let notificationBadgeCount_str = (GET_NOTIFICATION_BADGE() as String)
             if (Int)(notificationBadgeCount_str) > 0 {
             
             let notificationBadgeCount_int = (Int)(notificationBadgeCount_str)
             SET_NOTIFICATION_BADGE("\(notificationBadgeCount_int!+1)")
             
             } else {
             SET_NOTIFICATION_BADGE("\(1)")
             }
             */
            let userInfoDic = userInfo["aps"] as! [String : Any]
            
            // Jitu Code
            if let _  = (userInfo["orderId"] as? String){
               let orderID = (userInfo["orderId"] as? String)
            }
           
            
            
            
            SET_NOTIFICATION_BADGE("\((userInfoDic["badge"] as? Int)!)")
            application.applicationIconBadgeNumber = (userInfoDic["badge"] as? Int)!
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_BADGE_UPDATE), object: nil)
            
            /////////////// -------- custom push view --------- ////////////////
            
            let color = UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
            let image = UIImage(named: "SearchPeyalaLogo")
            let title = ("\((userInfoDic["alert"] as? String)!)")
            let subtitle = ""
            let banner = Banner(title: title, subtitle: subtitle, image: image, backgroundColor: color)
            banner.springiness = .heavy
            banner.position = .top
            banner.shouldTintImage = false
            banner.didTapBlock = {
                PYLGlobals.globals.NotificationBannerTapped = true
                debugPrint("after tapping do the rest work here....")
                self.navigateToViewController(utilityStoryboard, viewControllerName: String(describing: PYLNotificationViewController.self))
            }
            // banner will be shown below navigation Bar
            //banner.show(view, duration: 3.0)
            // banner will be shown above navigation Bar
            banner.show(duration: 3.0)
            
            /////////////// -------- custom push view --------- ////////////////
            
        } else if (application.applicationState == .inactive || application.applicationState == .background) {
            
            let type = (userInfo["type"] as? String)
            if type != nil {
                
                switch type! {
                case "ADD_NOTIFICATION":
                    navigateToViewController(utilityStoryboard, viewControllerName: String(describing: PYLNotificationViewController.self))
                    
                case "OFFER_NOTIFICATION":
                    navigateToViewController(utilityStoryboard, viewControllerName: String(describing: PYLNotificationViewController.self))
                    
                case "EMERGENCY_ALERT":
                    navigateToViewController(utilityStoryboard, viewControllerName: String(describing: PYLNotificationViewController.self))
                    
                case "CONFIRM_BOOKING_UPDATE":
                    navigateToViewController(servicesStoryboard, viewControllerName: String(describing: PYLMyOrderViewController.self))
                    
                case "ORDER_RECIVEABLE_UPDATE":
                    navigateToViewController(servicesStoryboard, viewControllerName: String(describing: PYLMyOrderViewController.self))
                    
                default:
                    break
                }
            }
        }
    }
    
    //MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "in.co.indusnet.Peyala" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Peyala", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    //MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - User Defined functions
    func appInitializers() {
        
        //fetch userDict from user-defaults
        if let userDict = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY) {
            PYLHelper.helper.userModelObj = ModelUser(userID: userDict["userID"] as? String, firstName: userDict["firstName"] as? String, lastName: userDict["lastName"] as? String, email: userDict["email"] as? String, address: userDict["address"] as? String, profileImageUrl: userDict["profileImageUrl"] as? String,phone:userDict["phone"] as? String,zipCode:userDict["zipCode"] as? String,gender:userDict["gender"] as? String,dob:userDict["dob"] as? String,loyaltypoint : userDict["loyaltypoint"] as? String,loyaltypercentage : userDict["loyaltypercentage"] as? String, loyaltycash: userDict["loyaltycash"] as? String,loyaltyunitvalue: userDict["loyaltyunitvalue"] as? String)
        }
        
        //fetch sessionID
        if let sessionId = GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) {
            PYLHelper.helper.sessionID = sessionId as? String
        }
        
        PYLHelper.helper.deviceID = "Simulator"
        let appRunCount = GET_APP_RUN_COUNT()
        SET_APP_RUN_COUNT(appRunCount.isBlank ? 0 : Int(appRunCount)! + 1)
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func navigateToViewController(_ storyBoard:UIStoryboard, viewControllerName:String) {
        
        guard PYLNavigationHelper.helper.navigationController?.topViewController?.className !=  viewControllerName  else {
            //TODO: post notification for API call
            return
        }
        let viewController = storyBoard.instantiateViewController(withIdentifier: viewControllerName)
        removeViewControllerFromNavigationStacks(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func removeViewControllerFromNavigationStacks(_ viewController : String) {
        
        for item in PYLNavigationHelper.helper.navigationController.viewControllers {
            if viewController.contains(item.className) {
                debugPrint("hasviewcontroller here")
                PYLNavigationHelper.helper.navigationController.viewControllers.removeObject(item)
            }
        }
    }
    
    //MARK: GA Configuration
    func configureGAnalytics() {
        
        // [START tracker_swift]
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.defaultTracker.allowIDFACollection = true
        // for AdWord
        gai?.defaultTracker.allowIDFACollection = true
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  //TODO: remove before app release
        //TODO: - need to change bundle ID at GoogleService-Info.plist as well
        // [END tracker_swift]
    }
}
