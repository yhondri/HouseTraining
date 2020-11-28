//
//  WorkoutExerciseEntity+CoreDataClass.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//
//

import Foundation
import CoreData

@objc(WorkoutExerciseEntity)
public class WorkoutExerciseEntity: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = WorkoutExerciseEntity.entity(managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
    }
    
    static func entity(_ managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entity(forEntityName: WorkoutExerciseEntity.className, in: managedObjectContext)
    }
    
    static func insert(exercises: [Exercise], in workout: WorkoutEntity, context: NSManagedObjectContext) {
        for exercise in exercises {
            guard let foundExercise = ExerciseEntity.getByID(exercise.getId().toInt64(), context: context) else {
                debugPrint("Error exercise not found on Insert WorkoutExerciseEntity")
                continue
            }
            let workoutExerciseEntity = WorkoutExerciseEntity(context: context)
            workoutExerciseEntity.position = exercise.position.toInt64()
            workoutExerciseEntity.exercise = foundExercise
            workoutExerciseEntity.workout = workout
        }
    }
}
