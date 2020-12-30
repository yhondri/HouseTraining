//
//  ExerciseEntity+CoreDataProperties.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 17/12/20.
//
//

import Foundation
import CoreData


extension ExerciseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseEntity> {
        return NSFetchRequest<ExerciseEntity>(entityName: "ExerciseEntity")
    }

    @NSManaged public var actionType: String
    @NSManaged public var exerciseId: Int64
    @NSManaged public var imageName: String
    @NSManaged public var name: String
    @NSManaged public var workoutLastDate: Date?
    @NSManaged public var exerciseRecords: ExerciseRecordEntity?
    @NSManaged public var workoutExercise: NSSet?

}

// MARK: Generated accessors for workoutExercise
extension ExerciseEntity {

    @objc(addWorkoutExerciseObject:)
    @NSManaged public func addToWorkoutExercise(_ value: WorkoutExerciseEntity)

    @objc(removeWorkoutExerciseObject:)
    @NSManaged public func removeFromWorkoutExercise(_ value: WorkoutExerciseEntity)

    @objc(addWorkoutExercise:)
    @NSManaged public func addToWorkoutExercise(_ values: NSSet)

    @objc(removeWorkoutExercise:)
    @NSManaged public func removeFromWorkoutExercise(_ values: NSSet)

}

extension ExerciseEntity : Identifiable {

}
