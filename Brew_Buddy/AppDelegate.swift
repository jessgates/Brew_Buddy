//
//  AppDelegate.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Set the data model
    let dataStack = CoreDataStack(modelName: "BrewBuddyDataModel")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set the style of the tab bar, status bar, and navigation bar across the app
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.tintColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        navigationBarAppearance.barTintColor = UIColor(red:1.00, green:0.40, blue:0.00, alpha:1.0)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)]
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let tabBarAppearance = UITabBar.appearance()
        
        tabBarAppearance.tintColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        
        dataStack.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dataStack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataStack.save()
    }
}

