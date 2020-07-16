//
//  GameStateChangeNotification.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit

typealias GameStateChangeObserverViewController = UIViewController & GameStateChangeObserver

protocol GameStateChangeObserver: AnyObject {
    func gameManagerDidEnter(state: State, from previousState: State?)
}

struct GameStateChangeNotification {
    static let name = NSNotification.Name("GameStateChangeNotification")
    static let object = GameManager.shared
    
    let newStateKey = "newState"
    let previousStateKey = "previousState"

    let newState: State
    let previousState: State?
    
    init(newState: State, previousState: State?) {
        self.newState = newState
        self.previousState = previousState
    }
    
    init?(notification: Notification) {
        guard notification.name == Self.name, let newState = notification.userInfo?[newStateKey] as? State else {
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
        NotificationCenter.default.post(name: Self.name, object: Self.object, userInfo: userInfo)
    }
}
