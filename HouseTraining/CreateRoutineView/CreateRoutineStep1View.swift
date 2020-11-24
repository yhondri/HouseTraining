//
//  CreateRoutineView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import SwiftUI

struct CreateRoutineStep1View: View {
    @EnvironmentObject var createRoutineViewModel: CreateRoutineViewModel
    @Environment(\.presentationMode) var presentation
    let exercises: [Exercise] = Exercise.getAvaialableExercises()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(exercises, id: \.self) { exercise in
                    CreateRoutineRowView(exercise: exercise)
                        .roundedCorner()
                }
            }
            .padding(.top, 10)
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarItems(trailing:
                                NavigationLink(destination: CreateRoutineStep2View()) {
                                    Text("Next 1 - 3")
                                }
//                                Button(LocalizableKey.save.localized) {
//                                    createRoutineViewModel.saveRoutine()
//
//                                }
        )
        .navigationBarTitle(Text(LocalizableKey.newRoutine.localized))
    }
}

struct CreateRoutineRowView: View {
    @EnvironmentObject var createRoutineViewModel: CreateRoutineViewModel
    let exercise: Exercise
    
    var body: some View {
        HStack {
            Image("ic_temp_activity")
                .padding(.trailing, 8)
            Text(exercise.actionName)
            Spacer()
            Button(action: {
                if createRoutineViewModel.exerciseIsAdded(exercise: exercise) {
                    createRoutineViewModel.deleteExercise(exercise)
                } else {
                    createRoutineViewModel.addExercise(exercise)
                }
            }) {
                if createRoutineViewModel.exerciseIsAdded(exercise: exercise) {
                    Image(systemName: "minus")
                } else {
                    Image(systemName: "plus")
                }
            }
        }.padding(.leading)
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineStep1View()
            .environmentObject(CreateRoutineViewModel())
    }
}
