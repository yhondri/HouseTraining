//
//  JumpingJack.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import Foundation

class JumpingJacks: Exercise {    
    init(workoutDate: Date? = nil) {
        super.init(id: 2,
                   actionType: .jumpingJacks,
                   actionName: LocalizableKey.jumpingJacks.localized,
                   workoutDate: workoutDate,
                   imageName: "noun_jumping_jacks")
    }
}


#if DEBUG
extension JumpingJacks {
    static func getPreview() -> JumpingJacks {
        let jumpingJacks = JumpingJacks()
        let action = Action(type: .jumpingJacks, probability: 98.65)
        jumpingJacks.didDectectAction(action: action)
        return jumpingJacks
    }
}
#endif
