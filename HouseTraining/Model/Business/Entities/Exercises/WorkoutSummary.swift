//
//  WorkoutSummary.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import UIKit

struct WorkoutSummary {
    let duration: Double
    let successRate: Double
    let heartRate: Double
    let caloriesBurned: Double
    let exercises: [Exercise]
    
    init(duration: Double,
         successRate: Double = 0.0,
         heartRate: Double = 0.0,
         caloriesBurned: Double = 0.0,
         exercises: [Exercise]) {
        self.duration = duration
        self.successRate = successRate
        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
        self.exercises = exercises
    }
}

#if DEBUG
extension WorkoutSummary {
    static func getPreview() -> WorkoutSummary {
        let exercises = [JumpingJacks.getPreview()]
        return WorkoutSummary(duration: 30,
                              successRate: 98,
                              heartRate: 156,
                              caloriesBurned: 222,
                              exercises: exercises)
    }
}
#endif
