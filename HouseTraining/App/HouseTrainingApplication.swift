//
//  HouseTrainingApplication.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import SwiftUI

@main
struct HouseTrainingApplication: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    private let dependency = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            AppView()
//                .environmentObject(dependency.indicatorInteractor)
//                .environmentObject(dependency.settingsViewModel)
        }
    }
}

