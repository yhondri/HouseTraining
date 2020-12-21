//
//  WorkoutSummaryViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 17/12/20.
//

import SwiftUI

class WorkoutSummaryViewModel: ObservableObject {

    @Published var workoutSummary: WorkoutSummary
    
    init(workoutSummary: WorkoutSummary) {
        self.workoutSummary = workoutSummary
    }
    
    func saveSummary() {
        ExerciseRecordEntity.insert(exercises: workoutSummary.exercises, context: CoreDataStack.shared.viewContext)
        CoreDataStack.shared.saveViewContext()
    }
}
