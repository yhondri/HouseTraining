//
//  AppViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import Foundation

struct AppViewModel {
    
    func setupDataIfNeeded() {
        guard ExerciseEntity.fetchAll(in: CoreDataStack.shared.viewContext).count == 0 else {
            return
        }
        
        ExerciseEntity.insert(exercises: Exercise.getAvaialableExercises(), context: CoreDataStack.shared.viewContext)
        CoreDataStack.shared.saveViewContext()
    }
}
