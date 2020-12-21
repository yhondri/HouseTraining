//
//  ExerciseRecordEntity+CoreDataClass.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 17/12/20.
//
//

import Foundation
import CoreData

@objc(ExerciseRecordEntity)
public class ExerciseRecordEntity: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = ExerciseRecordEntity.entity(managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
    }
    
    static func entity(_ managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entity(forEntityName: ExerciseRecordEntity.className, in: managedObjectContext)
    }
    
    static func insert(exercises: [Exercise], context: NSManagedObjectContext) {
        for exercise in exercises {
            guard let exerciseEntity = ExerciseEntity.getByID(exercise.getId().toInt64(), context: context) else { continue }
            let exerciseRecord = ExerciseRecordEntity(context: context)
            exerciseRecord.date = Date()
            exerciseRecord.score = 10
            exerciseRecord.exercise = exerciseEntity
        }
    }
    
    static func getAllFetchRequest(by date: Date) -> NSFetchRequest<ExerciseRecordEntity> {
        let startOfWeekDate = date.startOfWeek
        let endOfWeekDate = date.endOfWeek
        let fetchRequest: NSFetchRequest<ExerciseRecordEntity> = ExerciseRecordEntity.fetchRequest()
        let arguments: [Any] = [startOfWeekDate as NSDate, endOfWeekDate as NSDate]
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: arguments)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return fetchRequest
    }
}
