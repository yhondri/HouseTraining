//
//  NSManagedObject+Extension.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import CoreData

extension NSManagedObject {
    static func fetchAll(predicate: NSPredicate? = nil,
                         sortDescriptors: [NSSortDescriptor]? = nil,
                         fetchLimit: Int? = nil,
                         in context: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = self.fetchRequest()
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        do {
            return try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }
}
