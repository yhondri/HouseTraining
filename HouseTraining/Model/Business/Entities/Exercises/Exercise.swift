//
//  Exercise.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import Foundation

class Exercise: NSObject {
    static let exerciseTime = 30 //seconds
    private(set) var id: Int64
    private let minProbability: Double = 50.0
    private(set) var totalScore: Double = 0.0
    private var numberOfActionDetected = 0
    var actionType: ActionType
    var actionName: String
    var workoutDate: Date?
    var imageName: String
    var scoreValue: String {
        if numberOfActionDetected == 0 {
            return "0%"
        } else {
            return "\(averageScore.getWithTwoDecimals())%"
        }
    }
    
    var averageScore: Double {
        totalScore/Double(numberOfActionDetected)
    }
    
    var position: Int = 0
    
    init(id: Int64 = 0,
         actionType: ActionType = .none,
         actionName: String = "--",
         workoutDate: Date? = nil,
         imageName: String = "ic_temp_activity") {
        self.id = id
        self.actionType = actionType
        self.actionName = actionName
        self.workoutDate = workoutDate
        self.imageName = imageName
    }
    
//    func getId() -> Int {
//        fatalError("Not implemented")
//    }
    
    /**
     Actualiza las estadísticas del ejercicio que se está haciendo.
     
     Calcula a partir de la acción recibida la puntuación del ejercicio que está realizando el usuario. Primero se comprueba que la acción detectada es la del ejercicio esperado y a continuación se suma la fidelidad/precisión de la acción detectada sí y sólo sí esta es superior al 50%.
     
     - Parameter action: La acción detectada
     */
    
    func didDectectAction(action: Action) {
        guard action.type == actionType else { return }
        
        numberOfActionDetected += 1
        
        if action.probability >= minProbability {
            totalScore += action.probability
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
