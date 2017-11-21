//
//  AppDelegate.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: Coordinator!
    var coordinatorAssembly:AssemblyCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let rootViewController = UINavigationController();
        rootViewController.isNavigationBarHidden = true
        application.statusBarStyle = .lightContent

        let router = Router(navController:rootViewController)
        coordinatorAssembly = AssemblyCoordinator(router)
        appCoordinator = coordinatorAssembly.appCoordinator
        
        window = UIWindow.init(frame:UIScreen.main.bounds);
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        appCoordinator.start()
        
        return true
    }
}

