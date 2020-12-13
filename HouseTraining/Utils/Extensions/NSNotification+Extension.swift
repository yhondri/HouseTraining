//
//  NSNotification+Extension.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import Foundation

extension NSNotification.Name {
    ///Para notificar de que se cierre el workflow de crear un Workout.
    static let createWorkoutDismiss = Notification.Name("createWorkoutDismiss")
    static let dismissWorkoutWorkflow = Notification.Name("dismissWorkoutWorkflow")
}
