//
//  AppDelegate.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    // Set the data model
    let dataStack = CoreDataStack(modelName: "BrewBuddyDataModel")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        locationManager.delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Set the style of the tab bar, status bar, and navigation bar across the app
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.tintColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        navigationBarAppearance.barTintColor = UIColor(red:1.00, green:0.40, blue:0.00, alpha:1.0)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)]
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let tabBarAppearance = UITabBar.appearance()
        
        tabBarAppearance.tintColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        
        // Request authorization to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
            } else {
                print(error?.localizedDescription as Any)
            }
        }
        
        dataStack.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dataStack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataStack.save()
    }
    
    // Send notification of a nearby brewery
    func handleEvent(forRegion region: CLRegion!) {
        let identifier = "breweryNotification"

        let content = UNMutableNotificationContent()
        content.title = "\(region.identifier) is close by!"
        content.body = "Stop in and have a drink!"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        print(request)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
    }
}

//MARK:  CLLocationManager Delegate Method

extension AppDelegate: CLLocationManagerDelegate {
    
    // Listen for device entereing region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
}

//MARK: UNUserNotificationCenter Delegate Methods

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notification when tapped by user
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        completionHandler()
    }
    
    
    // Allow for notification receipt when app is in use
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

