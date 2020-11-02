//
//  JumpingJack.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import Foundation

protocol Exercise {
    var actionType: ActionType { get }
    var actionName: String { get }
    var scoreValue: String { get }

    /**
     Actualiza las estadísticas del ejercicio que se está haciendo.
     
     Calcula a partir de la acción recibida la puntuación del ejercicio que está realizando el usuario. Primero se comprueba que la acción detectada es la del ejercicio esperado y a continuación se suma la fidelidad/precisión de la acción detectada sí y sólo sí esta es superior al 50%.
     
     - Parameter action: La acción detectada
     */
    mutating func didDectectAction(action: Action)
}

struct JumpingJacks: Exercise {
    private var score: Double = 0.0
    private var numberOfActionDetected = 0
    var actionType: ActionType = .jumpingJacks
    var actionName: String = "Jumping Jacks"
    var scoreValue: String {
        "\(score)%"
    }
    
    mutating func didDectectAction(action: Action) {
        numberOfActionDetected += 1
        
        if action.probability >= 50 {
            score += action.probability
        }
    }
}


#if DEBUG
extension JumpingJacks {
    static func getPreview() -> JumpingJacks {
        return JumpingJacks()
    }
}
#endif
