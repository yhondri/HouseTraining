//
//  AppDelegate.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit
import CoreData
import SwiftUI

//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    /// set orientations you want to be allowed in this property by default
    var orientationLock: UIInterfaceOrientationMask = .portrait//UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        window = UIWindow()
//        let viewModel = WorkoutViewModel(actions: [.jumpingJacks])
//        let viewController = WorkoutViewController(viewModel: viewModel)
//        window?.rootViewController = UINavigationController(rootViewController: viewController)
//        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}

