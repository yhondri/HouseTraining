//
//  HighKneesRunInPlace.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class HighKneesRunInPlace: Exercise {
    init(workoutDate: Date? = nil) {
        super.init(id: 1,
                   actionType: .highKneesRunInPlace,
                   actionName: LocalizableKey.highKneesRunInPlace.localized,
                   workoutDate: workoutDate,
                   imageName: "noun_high_knees")
    }
}

#if DEBUG
extension HighKneesRunInPlace {
    static func getPreview() -> HighKneesRunInPlace {
        return HighKneesRunInPlace()
    }
}
#endif
