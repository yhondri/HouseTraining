//
//  WorkoutExerciseEntity+CoreDataProperties.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//
//

import Foundation
import CoreData


extension WorkoutExerciseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutExerciseEntity> {
        return NSFetchRequest<WorkoutExerciseEntity>(entityName: "WorkoutExerciseEntity")
    }

    @NSManaged public var position: Int64
    @NSManaged public var workout: WorkoutEntity?
    @NSManaged public var exercise: ExerciseEntity?

}

extension WorkoutExerciseEntity : Identifiable {

}
