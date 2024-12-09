//
//  AppDelegate.swift
//  OpenCap
//
//  Created by Nik on 15.09.2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let cameraViewController = CameraViewController()
        self.window?.rootViewController = cameraViewController
        self.window?.makeKeyAndVisible()
        return true
    }
}
