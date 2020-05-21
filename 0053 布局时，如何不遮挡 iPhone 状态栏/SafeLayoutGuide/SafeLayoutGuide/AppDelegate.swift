//
//  AppDelegate.swift
//  SafeLayoutGuide
//
//  Created by songzhou on 2020/5/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        
        window?.makeKeyAndVisible()
        return true
    }

    var window: UIWindow?
}

