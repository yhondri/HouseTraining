//
//  WorkoutSummary.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import UIKit

struct WorkoutSummary {
    let duration: Double
    let heartRate: Double
    let caloriesBurned: Double
    let exercises: [Exercise]
    var successRate: Double {
        let sum = exercises.lazy.map { $0.averageScore }.reduce(0, +)
        if sum == 0 {
            return 0
        }
        return sum/Double(exercises.count)
    }
    
    init(duration: Double,
         heartRate: Double = 0.0,
         caloriesBurned: Double = 0.0,
         exercises: [Exercise]) {
        self.duration = duration

        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
        self.exercises = exercises
    }
    
    
}

//#if DEBUG
extension WorkoutSummary {
    static func getPreview() -> WorkoutSummary {
        let exercises = [JumpingJacks.getPreview()]
        return WorkoutSummary(duration: 30,
                              heartRate: 156,
                              caloriesBurned: 222,
                              exercises: exercises)
    }
}
//#endif
