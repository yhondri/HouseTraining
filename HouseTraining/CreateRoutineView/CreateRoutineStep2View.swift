//
//  CreateRoutineStep2View.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 24/11/20.
//

import SwiftUI

struct CreateRoutineStep2View: View {
    @State var exercises: [Exercise] = Exercise.getAvaialableExercises()
    @State private var isEditable = false

    var body: some View {
//        ScrollView {
            List {
                ForEach(exercises, id: \.self) { exercise in
                    CreateRoutineRow2View(exercise: exercise)
                        .roundedCorner()
                }
                .onMove(perform: move)
                .onLongPressGesture {
                                withAnimation {
                                    self.isEditable = true
                                }
                            }
            }
            .padding(.top, 10)
            .environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive))

//        }
//        .background(Color.tableViewBackgroundColor)
//        .navigationBarItems(trailing:
//                                NavigationLink(destination: CreateRoutineStep2View()) {
//                                    Text("Next 1 - 3")
//                                }
////                                Button(LocalizableKey.save.localized) {
////                                    createRoutineViewModel.saveRoutine()
////
////                                }
//        )
        .navigationBarTitle(Text(LocalizableKey.newRoutine.localized))
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        withAnimation {
            isEditable = false
        }
    }
}

struct CreateRoutineRow2View: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            Image("ic_temp_activity")
                .padding(.trailing, 8)
            Text(exercise.actionName)
            Spacer()
        }.padding(.leading)
    }
}


struct CreateRoutineStep2View_Previews: PreviewProvider {
    static var previews: some View {
        let tempExercises = Exercise.getAvaialableExercises()
        CreateRoutineStep2View(exercises: tempExercises)
    }
}
