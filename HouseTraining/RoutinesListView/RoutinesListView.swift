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

    @ViewBuilder var body: some View {
        getView()
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
    
    private func getView() -> some View {
        if workoutList.isEmpty {
            return AnyView(getEmtpyView())
        } else {
            return AnyView(getBodyWithData())
        }
    }
    
    private func getEmtpyView() -> some View {
        VStack(alignment: .center) {
            Image("no_workout_data")
                .resizable()
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Text(LocalizableKey.workoutsNoData.localized)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private func getBodyWithData() ->  some View {
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
