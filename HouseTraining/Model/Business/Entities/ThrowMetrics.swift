//
//  ThrowMetrics.swift
//  ShakeIt
//
//  Created by Yhondri Acosta Novas on 14/07/2020.
//

import UIKit

struct ThrowMetrics {
    var score = Scoring.zero
    var releaseSpeed = 0.0
    var releaseAngle = 0.0
    var throwType = ActionType.none
    var finalBagLocation: CGPoint = .zero

    mutating func updateThrowType(_ type: ActionType) {
        throwType = type
    }

    mutating func updateFinalBagLocation(_ location: CGPoint) {
        finalBagLocation = location
    }

    mutating func updateMetrics(newScore: Scoring, speed: Double, angle: Double) {
        score = newScore
        releaseSpeed = speed
        releaseAngle = angle
    }
}
