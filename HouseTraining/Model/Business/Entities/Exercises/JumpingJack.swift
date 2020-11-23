//
//  JumpingJack.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import Foundation

class JumpingJacks: Exercise {
    private let id: Int = 2
    
    init(workoutLastDate: Date? = nil) {
        super.init(actionType: .jumpingJacks, actionName: LocalizableKey.jumpingJacks.localized, workoutLastDate: workoutLastDate)
    }
}


#if DEBUG
extension JumpingJacks {
    static func getPreview() -> JumpingJacks {
        return JumpingJacks()
    }
}
#endif
