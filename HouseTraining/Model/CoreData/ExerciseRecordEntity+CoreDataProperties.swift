//
//  ExerciseRecordEntity+CoreDataProperties.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 17/12/20.
//
//

import Foundation
import CoreData


extension ExerciseRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseRecordEntity> {
        return NSFetchRequest<ExerciseRecordEntity>(entityName: "ExerciseRecordEntity")
    }

    @NSManaged public var date: Date
    @NSManaged public var score: Double
    @NSManaged public var exercise: ExerciseEntity?

}

extension ExerciseRecordEntity : Identifiable {

}
