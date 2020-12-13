//
//  RoutinesListView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import SwiftUI

struct RoutinesListView: View {
    @State var showingCreateRoutineView = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: WorkoutEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntity.name, ascending: true)]
    ) var workoutList: FetchedResults<WorkoutEntity>
    
    @State var workoutViewIsActive = false

    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(workoutList, id: \.self) { workout in
                    NavigationLink(
                        destination: WorkoutViewControllerRepresentable(workoutEntity: workout),
                        isActive: $workoutViewIsActive,
                        label: {
                            RoutineView(workout: workout)
                                .roundedCorner()
                        })
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
            }.onReceive(NotificationCenter.default.publisher(for: .dismissWorkoutWorkflow)) { _ in
                workoutViewIsActive = false
            }.onAppear {
                Tool.showTabBar()
            }
        )
        .navigationBarTitle(Text(LocalizableKey.workouts.localized))
    }
}

struct RoutineView: View {
    let workout: WorkoutEntity
    var body: some View {
        HStack {
            Image("ic_temp_activity")
                .padding(.trailing, 8)
            Text(workout.name)
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
