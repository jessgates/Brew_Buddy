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
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
            }
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        dataStack.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dataStack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataStack.save()
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        
        if UIApplication.shared.applicationState == .active {
            displayAlert("Stop in and have a drink!", region: region.identifier)
        } else {
            let content = UNMutableNotificationContent()
            content.title = region.identifier
            content.body = "Stop in and have a drink!"
            content.sound = UNNotificationSound.default()
        
            let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
            let request = UNNotificationRequest(identifier: "breweryNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if (error != nil) {
                print("request not added")
                }
            }
        }
    }
    
    func displayAlert(_ alertString: String?, region: String) {
        let alertController = UIAlertController(title: region, message: alertString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
}

