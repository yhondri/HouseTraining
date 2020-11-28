//
//  Exercise.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class Exercise: NSObject {
    private let minProbability: Double = 50.0
    private(set) var score: Double = 0.0
    private var numberOfActionDetected = 0
    var actionType: ActionType
    var actionName: String
    var workoutLastDate: Date?
    var imageName: String
    var scoreValue: String {
        "\(score)%"
    }
    
    private let id: Int = 0
    var position: Int = 0
    
    init(actionType: ActionType = .none,
         actionName: String = "--",
         workoutLastDate: Date? = nil,
         imageName: String = "ic_temp_activity") {
        self.actionType = actionType
        self.actionName = actionName
        self.workoutLastDate = workoutLastDate
        self.imageName = imageName
    }
    
    func getId() -> Int {
        return id
    }
    
    /**
     Actualiza las estadísticas del ejercicio que se está haciendo.
     
     Calcula a partir de la acción recibida la puntuación del ejercicio que está realizando el usuario. Primero se comprueba que la acción detectada es la del ejercicio esperado y a continuación se suma la fidelidad/precisión de la acción detectada sí y sólo sí esta es superior al 50%.
     
     - Parameter action: La acción detectada
     */
    
    func didDectectAction(action: Action) {
        numberOfActionDetected += 1
        
        if action.probability >= minProbability {
            score += action.probability
        }
    }
    
    static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
       return lhs.id == rhs.id
    }
}

extension Exercise {
    static func getAvaialableExercises() -> [Exercise] {
        [HighKneesRunInPlace(), JumpingJacks(), Plank(), SumoSquat(), WallSit()]
    }
}
