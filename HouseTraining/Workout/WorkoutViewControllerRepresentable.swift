//
//  WorkoutViewControllerRepresentable.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 31/3/21.
//

import SwiftUI

struct WorkoutViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = WorkoutViewController
    var workoutEntity: WorkoutEntity?
    var exerciseEntity: ExerciseEntity?
    
    init(workoutEntity: WorkoutEntity? = nil, exerciseEntity: ExerciseEntity? = nil) {
        self.workoutEntity = workoutEntity
        self.exerciseEntity = exerciseEntity
    }
    
    func makeUIViewController(context: Context) -> WorkoutViewController {
        var actions: [ActionType]
        if let workoutExercises = workoutEntity?.exercises?.allObjects as? [WorkoutExerciseEntity] {
            actions = workoutExercises.compactMap {  workoutEntity  -> ActionType? in
                guard let action = workoutEntity.exercise?.actionType,  let actionType = ActionType(rawValue: action) else {
                    return nil
                }
                return actionType
            }
        } else if let actionTypeString = exerciseEntity?.actionType,
                  let actionType = ActionType(rawValue: actionTypeString) {
            actions = [actionType]
        } else {
            fatalError("No puedes inicializar este módulo sin una acción válida")
        }
        
        let viewModel = WorkoutViewModel(actions: actions)
        return WorkoutViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: WorkoutViewController, context: Context) {}
}
