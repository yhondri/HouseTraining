//
//  WorkoutEntity+CoreDataClass.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//
//

import Foundation
import CoreData

@objc(WorkoutEntity)
public class WorkoutEntity: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = WorkoutEntity.entity(managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
    }
    
    static func entity(_ managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entity(forEntityName: WorkoutEntity.className, in: managedObjectContext)
    }
    
    static func insert(workoutName: String, exercises: [Exercise], context: NSManagedObjectContext) {
        let workoutEntity = WorkoutEntity(context: context)
        workoutEntity.name = workoutName
        WorkoutExerciseEntity.insert(exercises: exercises, in: workoutEntity, context: context)
    }
}
