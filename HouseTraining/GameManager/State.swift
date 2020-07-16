//
//  State.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import GameKit

class State: GKState {
    private(set) var validNextStates: [State.Type]
    
    init(_ validNextStates: [State.Type]) {
        self.validNextStates = validNextStates
        super.init()
    }
    
    func addValidNextState(_ state: State.Type) {
        validNextStates.append(state)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return validNextStates.contains(where: { stateClass == $0 })
    }
    
    override func didEnter(from previousState: GKState?) {
        let note = GameStateChangeNotification(newState: self, previousState: previousState as? State)
        note.post()
    }
}

class InactiveState: State {
}

class SetupCameraState: State {
}

class DetectingPlayerState: State {
}

class DetectedPlayerState: State {
}

class TrackThrowsState: State {
}

class ThrowCompletedState: State {
}

class ShowSummaryState: State {
}
