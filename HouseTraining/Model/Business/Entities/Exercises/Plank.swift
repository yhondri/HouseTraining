//
//  Plank.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class Plank: Exercise {
    init(workoutDate: Date? = nil) {
        super.init(id: 3,
                   actionType: .plank,
                   actionName: LocalizableKey.plank.localized,
                   workoutDate: workoutDate,
                   imageName: "noun_basic_plank")
    }
}

#if DEBUG
extension Plank {
    static func getPreview() -> Plank {
        return Plank()
    }
}
#endif
