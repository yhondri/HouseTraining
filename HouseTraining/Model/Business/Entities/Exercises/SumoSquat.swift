//
//  SumoSquat.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class SumoSquat: Exercise {
    init(workoutLastDate: Date? = nil) {
        super.init(actionType: .sumoSquat, actionName: LocalizableKey.sumoSquat.localized, workoutLastDate: workoutLastDate)
    }
}

#if DEBUG
extension SumoSquat {
    static func getPreview() -> SumoSquat {
        return SumoSquat()
    }
}
#endif
