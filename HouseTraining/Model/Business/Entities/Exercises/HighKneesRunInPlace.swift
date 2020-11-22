//
//  HighKneesRunInPlace.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class HighKneesRunInPlace: Exercise {
    init(workoutLastDate: Date? = nil) {
        super.init(actionType: .highKneesRunInPlace, actionName: LocalizableKey.highKneesRunInPlace.localized, workoutLastDate: workoutLastDate)
    }
}

#if DEBUG
extension HighKneesRunInPlace {
    static func getPreview() -> HighKneesRunInPlace {
        return HighKneesRunInPlace()
    }
}
#endif
