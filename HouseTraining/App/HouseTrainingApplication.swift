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
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
        }
    }
}

