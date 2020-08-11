//
//  GameManager.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import GameKit

class ExerciseManager: NSObject {
    fileprivate var activeObservers = [UIViewController: NSObjectProtocol]()
    fileprivate var activeObjectsObservers = [NSObject: NSObjectProtocol]()

    let stateMachine: GKStateMachine
    var boardRegion = CGRect.null
    var holeRegion = CGRect.null
    var recordedVideoSource: AVAsset?
    var playerStats = PlayerStats()
    var lastThrowMetrics = ThrowMetrics()
    var pointToMeterMultiplier = Double.nan
    var previewImage = UIImage()
    
    static var shared = ExerciseManager()
    
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

//TODO: Delete this
//extension ExerciseStateChangeObserver where Self: UIViewController {
//    func startObservingStateChanges() {
//        let token = NotificationCenter.default.addObserver(forName: .exerciseStateChangeNotification,
//                                                           object: ExerciseStateChangeNotification.object,
//                                                           queue: nil) { [weak self] (notification) in
//            guard let note = ExerciseStateChangeNotification(notification: notification) else {
//                return
//            }
//            self?.gameManagerDidEnter(state: note.newState, from: note.previousState)
//        }
//        let gameManager = ExerciseManager.shared
//        gameManager.activeObservers[self] = token
//    }
//    
//    func stopObservingStateChanges() {
//        let gameManager = ExerciseManager.shared
//        guard let token = gameManager.activeObservers[self] else {
//            return
//        }
//        NotificationCenter.default.removeObserver(token)
//        gameManager.activeObservers.removeValue(forKey: self)
//    }
//}

extension ExerciseStateChangeObserver where Self: NSObject {
    func startObservingStateChanges() {
        let token = NotificationCenter.default.addObserver(forName: .exerciseStateChangeNotification,
                                                           object: ExerciseStateChangeNotification.object,
                                                           queue: nil) { [weak self] (notification) in
            guard let note = ExerciseStateChangeNotification(notification: notification) else {
                return
            }
            self?.gameManagerDidEnter(state: note.newState, from: note.previousState)
        }
        let gameManager = ExerciseManager.shared
        gameManager.activeObjectsObservers[self] = token
    }
    
    func stopObservingStateChanges() {
        let gameManager = ExerciseManager.shared
        guard let token = gameManager.activeObjectsObservers[self] else {
            return
        }
        NotificationCenter.default.removeObserver(token)
        gameManager.activeObjectsObservers.removeValue(forKey: self)
    }
}

