//
//  CreateRoutineViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import UIKit


class CreateRoutineViewModel: ObservableObject {
    @Published var canGoToNextView: Bool = false
    private var addedExercise: [Int: Bool] = [:]
    let availableExercises: [Exercise] = Exercise.getAvaialableExercises()

    init() {
        for i in 0..<availableExercises.count {
            addedExercise[i] = false
        }
    }
    
    func addExercise(at index: Int) {
        addedExercise[index] = true
        updateGoToNextView()
    }
    
    func deleteExercise(at index: Int) {
        addedExercise[index] = false
        updateGoToNextView()
    }
    
    func exerciseIsAdded(at index: Int) -> Bool {
        addedExercise[index] ?? false
    }
    
    func getExercises() -> [Exercise] {
        addedExercise.filter { $0.value }
            .map { availableExercises[$0.key] }
    }
    
    func updateGoToNextView() {
        canGoToNextView = addedExercise.first(where: { $0.value }) != nil
    }
    
    func saveRoutine() {
        
    }
}
