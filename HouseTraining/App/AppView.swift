//
//  AppView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TabView {
            NavigationView {
                ExerciseListView()
                    .navigationBarTitle(Text(LocalizableKey.exercises.localized))
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text(LocalizableKey.exercises.localized)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            //            NavigationView {
//                SettingsView()
//            }.tabItem {
//                Image(systemName: "gear")
//                Text(LocalizableKey.settings.localized)
//            }
//            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
