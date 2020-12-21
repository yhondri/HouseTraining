//
//  Plank.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class Plank: Exercise {
    private let id: Int = 3

    init(workoutDate: Date? = nil) {
        super.init(actionType: .plank, actionName: LocalizableKey.plank.localized, workoutDate: workoutDate)
    }
}

#if DEBUG
extension Plank {
    static func getPreview() -> Plank {
        return Plank()
    }
}
#endif
