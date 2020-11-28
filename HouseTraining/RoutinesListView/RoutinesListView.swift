//
//  RoutinesListView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import SwiftUI

struct RoutinesListView: View {
    @State var showingCreateRoutineView = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<5) { _ in 
                    RoutineView()
                        .roundedCorner()                    
                }
            }
            .padding(.top, 10)
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarItems(trailing:
                                Button(action: {
                                    showingCreateRoutineView.toggle()
                                }) {
                                    Image(systemName: "plus")
                                }
            .sheet(isPresented: $showingCreateRoutineView) {
                NavigationView {
                    CreateRoutineStep1View()
                }
            }.onReceive(NotificationCenter.default.publisher(for: .createWorkoutDismiss)) { _ in
                showingCreateRoutineView = false
            }
        )
        .navigationBarTitle(Text(LocalizableKey.routines.localized))
    }
}

struct RoutineView: View {
    var body: some View {
        HStack {
            Image("ic_temp_activity")
                .padding(.trailing, 8)
            Text("Routine")
            Spacer()
            Image(systemName: "chevron.right")
        }.padding(.leading)
    }
}

struct RoutinesListView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesListView()
    }
}
