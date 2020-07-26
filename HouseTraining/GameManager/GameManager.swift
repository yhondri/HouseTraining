//
//  GameManager.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import GameKit

class GameManager: NSObject {
    fileprivate var activeObservers = [UIViewController: NSObjectProtocol]()
    
    let stateMachine: GKStateMachine
    var boardRegion = CGRect.null
    var holeRegion = CGRect.null
    var recordedVideoSource: AVAsset?
    var playerStats = PlayerStats()
    var lastThrowMetrics = ThrowMetrics()
    var pointToMeterMultiplier = Double.nan
    var previewImage = UIImage()
    
    static var shared = GameManager()
    
    private override init() {
        // Possible states with valid next states.
        let states = [
            InactiveState([SetupCameraState.self]),
            SetupCameraState([DetectingPlayerState.self]),
            DetectingPlayerState([DetectedPlayerState.self]),
            DetectedPlayerState([TrackThrowsState.self]),
            TrackThrowsState([ThrowCompletedState.self, ShowSummaryState.self]),
            ThrowCompletedState([ShowSummaryState.self, TrackThrowsState.self]),
            ShowSummaryState([DetectingPlayerState.self])
        ]
        // Any state besides Inactive can be returned to Inactive.
        for state in states where !(state is InactiveState) {
            state.addValidNextState(InactiveState.self)
        }
        // Create state machine.
        stateMachine = GKStateMachine(states: states)
    }
    
//    func reset() {
//        // Reset all stored values
//        boardRegion = .null
//        recordedVideoSource = nil
//        playerStats = PlayerStats()
//        pointToMeterMultiplier = .nan
//        // Remove all observers and enter inactive state.
//        let notificationCenter = NotificationCenter.default
//        for observer in activeObservers {
//            notificationCenter.removeObserver(observer)
//        }
//        activeObservers.removeAll()
//        stateMachine.enter(InactiveState.self)
//    }
}

extension GameStateChangeObserver where Self: UIViewController {
    func startObservingStateChanges() {
        let token = NotificationCenter.default.addObserver(forName: GameStateChangeNotification.name,
                                                           object: GameStateChangeNotification.object,
                                                           queue: nil) { [weak self] (notification) in
            guard let note = GameStateChangeNotification(notification: notification) else {
                return
            }
            self?.gameManagerDidEnter(state: note.newState, from: note.previousState)
        }
        let gameManager = GameManager.shared
        gameManager.activeObservers[self] = token
    }
    
    func stopObservingStateChanges() {
        let gameManager = GameManager.shared
        guard let token = gameManager.activeObservers[self] else {
            return
        }
        NotificationCenter.default.removeObserver(token)
        gameManager.activeObservers.removeValue(forKey: self)
    }
}
