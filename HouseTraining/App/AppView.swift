//
//  AppView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import SwiftUI

struct AppView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    init() {
        AppViewModel().setupDataIfNeeded()
    }
    
    var body: some View {
        TabView {
            NavigationView {
                ChartGridView()
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text(LocalizableKey.charts.localized)
            }
            NavigationView {
                RoutinesListView()
            }
            .tabItem {
                Image(systemName: "flowchart")
                Text(LocalizableKey.workouts.localized)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                ExerciseListView()
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text(LocalizableKey.exercises.localized)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                MoreView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text(LocalizableKey.more.localized)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .accentColor(.charBarBottomColor)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
