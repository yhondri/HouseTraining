//
//  WallSit.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class WallSit: Exercise {
    init(workoutLastDate: Date? = nil) {
        super.init(actionType: .wallSit, actionName: LocalizableKey.wallSit.localized, workoutLastDate: workoutLastDate)
    }
}

#if DEBUG
extension WallSit {
    static func getPreview() -> WallSit {
        return WallSit()
    }
}
#endif
