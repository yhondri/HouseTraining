//
//  GameStateChangeNotification.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit

typealias ExerciseStateChangeObserverViewController = UIViewController & ExerciseStateChangeObserver

protocol ExerciseStateChangeObserver: AnyObject {
    func gameManagerDidEnter(state: State, from previousState: State?)
}

struct ExerciseStateChangeNotification {
    static let object = ExerciseManager.shared
    
    let newStateKey = "newState"
    let previousStateKey = "previousState"

    let newState: State
    let previousState: State?
    
    init(newState: State, previousState: State?) {
        self.newState = newState
        self.previousState = previousState
    }
    
    init?(notification: Notification) {
        guard notification.name == .exerciseStateChangeNotification, let newState = notification.userInfo?[newStateKey] as? State else {
            return nil
        }
        self.newState = newState
        self.previousState = notification.userInfo?[previousStateKey] as? State
    }
    
    func post() {
        var userInfo = [newStateKey: newState]
        if let previousState = previousState {
            userInfo[previousStateKey] = previousState
        }
        NotificationCenter.default.post(name: .exerciseStateChangeNotification, object: Self.object, userInfo: userInfo)
    }
}
