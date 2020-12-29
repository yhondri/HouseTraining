//
//  RoutineViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 29/12/20.
//

import SwiftUI

struct RoutineViewModel {
    func deleteWorkout(_ workoutEntity: WorkoutEntity) {
        WorkoutEntity.delete(workoutEntity: workoutEntity, context: CoreDataStack.shared.viewContext)
        CoreDataStack.shared.saveViewContext()
    }
}
