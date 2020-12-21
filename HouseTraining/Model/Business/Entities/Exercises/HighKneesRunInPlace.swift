//
//  HighKneesRunInPlace.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class HighKneesRunInPlace: Exercise {
    private let id: Int = 1
    
    init(workoutDate: Date? = nil) {
        super.init(actionType: .highKneesRunInPlace, actionName: LocalizableKey.highKneesRunInPlace.localized, workoutDate: workoutDate)
    }
}

#if DEBUG
extension HighKneesRunInPlace {
    static func getPreview() -> HighKneesRunInPlace {
        return HighKneesRunInPlace()
    }
}
#endif
