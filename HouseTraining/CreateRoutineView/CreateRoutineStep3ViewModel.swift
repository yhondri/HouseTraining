//
//  CreateRoutineStep3ViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import SwiftUI

class CreateRoutineStep3ViewModel: ObservableObject {
    let exercises: [Exercise]
    
    init(exercises: [Exercise]) {
        self.exercises = exercises
    }
    
    func saveWorkout(workoutName: String) {
        WorkoutEntity.insert(workoutName: workoutName, exercises: exercises, context: CoreDataStack.shared.viewContext)
        CoreDataStack.shared.saveViewContext()
    }
}
