//
//  CreateRoutineViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import UIKit

class CreateRoutineViewModel: ObservableObject {
    @Published var addedExercise: Set<Exercise> = []

    func addExercise(_ exercise: Exercise) {
        addedExercise.insert(exercise)
    }
    
    func deleteExercise(_ exercise: Exercise) {
        addedExercise.remove(exercise)
    }
    
    func exerciseIsAdded(exercise: Exercise) -> Bool {
        addedExercise.contains(exercise)
    }
    
    func saveRoutine() {
        
    }
}
