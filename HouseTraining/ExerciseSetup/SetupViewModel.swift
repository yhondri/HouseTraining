//
//  SetupViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 11/8/20.
//

import Combine
import Foundation.NSObject

public class SetupViewModel: NSObject {
    private let gameManager = ExerciseManager.shared
    var state = PassthroughSubject<State, Never>()

    func viewDidLoad() {
        startObservingStateChanges()
    }
    
    func viewDidAppear() {
        gameManager.stateMachine.enter(SetupCameraState.self)
        gameManager.stateMachine.enter(DetectingPlayerState.self)
    }
}

// MARK: - Handle states that require view controller transitions
extension SetupViewModel: ExerciseStateChangeObserver {
    func gameManagerDidEnter(state: State, from previousState: State?) {
        self.state.send(state)
    }
}
