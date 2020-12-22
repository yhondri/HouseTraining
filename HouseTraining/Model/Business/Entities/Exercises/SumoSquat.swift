//
//  SumoSquat.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class SumoSquat: Exercise {
    private let id: Int = 4

    init(workoutDate: Date? = nil) {
        super.init(actionType: .sumoSquat,
                   actionName: LocalizableKey.sumoSquat.localized,
                   workoutDate: workoutDate,
                   imageName: "noun_squatting")
    }
}

#if DEBUG
extension SumoSquat {
    static func getPreview() -> SumoSquat {
        return SumoSquat()
    }
}
#endif
