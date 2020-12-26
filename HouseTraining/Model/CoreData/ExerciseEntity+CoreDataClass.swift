//
//  ExerciseEntity+CoreDataClass.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//
//

import Foundation
import CoreData

@objc(ExerciseEntity)
public class ExerciseEntity: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = ExerciseEntity.entity(managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
    }
    
    static func entity(_ managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entity(forEntityName: ExerciseEntity.className, in: managedObjectContext)
    }
    
    static func insert(exercises: [Exercise], context: NSManagedObjectContext) {
        for exercise in exercises {
            let exerciseEntity = ExerciseEntity(context: context)
            exerciseEntity.id = exercise.id
            exerciseEntity.actionType = exercise.actionType.rawValue
            exerciseEntity.name = exercise.actionName
            exerciseEntity.workoutLastDate = exercise.workoutDate
            exerciseEntity.imageName = exercise.imageName
        }
    }
    
    //MARK: - Fetchs
    static func fetchAllExercises(context: NSManagedObjectContext) -> [Exercise] {
        guard let availableExercises = ExerciseEntity.fetchAll(in: CoreDataStack.shared.viewContext) as? [ExerciseEntity] else {
            return []
        }

        return availableExercises.map {
            Exercise(id: $0.id,
                     actionType: ActionType(rawValue: $0.actionType)!,
                     actionName: $0.name,
                     workoutDate: $0.workoutLastDate,
                     imageName: $0.imageName)
        }
    }
    
    static func getByID(_ id: Int64, context: NSManagedObjectContext) -> ExerciseEntity? {
        let predicate = NSPredicate(format: "id = %d", id)
        guard let exercises = ExerciseEntity.fetchAll(predicate: predicate,
                                                               fetchLimit: 1,
                                                               in: CoreDataStack.shared.viewContext) as? [ExerciseEntity] else {
            return nil
        }
        
        return exercises.first
    }
}
