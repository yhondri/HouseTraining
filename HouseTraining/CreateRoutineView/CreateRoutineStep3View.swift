//
//  CreateRoutineStep3View.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import SwiftUI

struct CreateRoutineStep3View: View {
    @StateObject var createRoutineViewModel: CreateRoutineStep3ViewModel
    @State var workoutName: String = ""

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    Section(header: TextField("Nombre entrenamiento", text: $workoutName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()) {
                        ForEach(createRoutineViewModel.exercises, id: \.self) { exercise in
                            CreateRoutineStep3RowView(exercise: exercise)
                                .roundedCorner(with: Color.itemBackgroundColor)
                        }
                    }
                }
                .padding(.top, 10)
            }
            VStack {
                Spacer()
                Button(LocalizableKey.save.localized, action: {
                    createRoutineViewModel.saveWorkout(workoutName: workoutName)
                    NotificationCenter.default.post(Notification(name: .createWorkoutDismiss))
                })
                .disabled(workoutName.isEmpty)
                .foregroundColor(.white)
                .padding([.top, .bottom], 10)
                .padding([.leading, .trailing], 40)
                .background(!workoutName.isEmpty ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            }
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarTitle(Text(LocalizableKey.save.localized))
    }
}

struct CreateRoutineStep3RowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.charBarBottomColor)
                    .frame(width: 50, height: 50)
                Image(exercise.imageName)
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            Text(exercise.actionName)
                .foregroundColor(.itemTextColor)
            Spacer()
        }
    }
}

struct CreateRoutineStep3View_Previews: PreviewProvider {
    static var previews: some View {
        let routineStep3ViewModel = CreateRoutineStep3ViewModel(exercises: Exercise.getAvaialableExercises())
        CreateRoutineStep3View(createRoutineViewModel: routineStep3ViewModel)
    }
}
