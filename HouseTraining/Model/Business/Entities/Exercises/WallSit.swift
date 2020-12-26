//
//  WallSit.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class WallSit: Exercise {
    init(workoutDate: Date? = nil) {
        super.init(id: 5,
                   actionType: .wallSit,
                   actionName: LocalizableKey.wallSit.localized,
                   workoutDate: workoutDate,
                   imageName: "noun_Wall_sit")
    }
}

#if DEBUG
extension WallSit {
    static func getPreview() -> WallSit {
        return WallSit()
    }
}
#endif
