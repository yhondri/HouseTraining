//
//  PlayerStats.swift
//  ShakeIt
//
//  Created by Yhondri Acosta Novas on 14/07/2020.
//

import UIKit
import Vision
import os.log

struct Action {
    let type: ActionType
    let probability: Double
    
    init(type: ActionType = .none, probability: Double = 0.0) {
        self.type = type
        self.probability = probability*100
    }
}

enum ActionType: String, CaseIterable {
    case highKneesRunInPlace = "high_knees_run_in_place"
    case jumpingJacks = "jacks"
    case plank = "plank"
    case sumoSquat = "sumo_squat"
    case wallSit = "wall_sit"
    case other = "other"
    case none = "None"
}

struct PlayerStatsConstants {
    static let maxPoseObservations = 60
}

struct PlayerStats {
    private var poseObservations = [VNHumanBodyPoseObservation]()
    
    var throwPaths = [CGPath]()

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if poseObservations.count >= PlayerStatsConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getAction() -> Action {
        guard let actionClassifier = try? PlayerActionClassifier(configuration: MLModelConfiguration()) else {
            return Action()
        }
        
        guard let poseMultiArray = prepareInputWithObservations(poseObservations) else {
            return Action()
        }
        
        guard let predictions = try? actionClassifier.prediction(poses: poseMultiArray) else {
            return Action()
        }
        
        guard let actionType = ActionType(rawValue: predictions.label) else {
            return Action()
        }

        return Action(type: actionType, probability: predictions.actionProbability)
    }
}

// MARK: - Activity Classification Helpers
func prepareInputWithObservations(_ observations: [VNRecognizedPointsObservation]) -> MLMultiArray? {
    let numAvailableFrames = observations.count
    let observationsNeeded = 60
    var multiArrayBuffer = [MLMultiArray]()

    for frameIndex in 0 ..< min(numAvailableFrames, observationsNeeded) {
        let pose = observations[frameIndex]
        do {
            let oneFrameMultiArray = try pose.keypointsMultiArray()
            multiArrayBuffer.append(oneFrameMultiArray)
        } catch {
            continue
        }
    }
    
    // If poseWindow does not have enough frames (45) yet, we need to pad 0s
    if numAvailableFrames < observationsNeeded {
        for _ in 0 ..< (observationsNeeded - numAvailableFrames) {
            do {
                let oneFrameMultiArray = try MLMultiArray(shape: [1 , 3, 18], dataType: .double)
                try resetMultiArray(oneFrameMultiArray)
                multiArrayBuffer.append(oneFrameMultiArray)
            } catch {
                continue
            }
        }
    }
    return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
}

func resetMultiArray(_ predictionWindow: MLMultiArray, with value: Double = 0.0) throws {
    let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
    pointer.initialize(repeating: value)
}


// MARK: - Errors
enum AppError: Error {
    case captureSessionSetup(reason: String)
    case createRequestError(reason: String)
    case videoReadingError(reason: String)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            print(error)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .createRequestError(let reason):
            title = "Error Creating Vision Request"
            message = reason
        case .videoReadingError(let reason):
            title = "Error Reading Recorded Video."
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        viewController.present(alert, animated: true)
    }
}

func getBodyJointsFor(observation: VNHumanBodyPoseObservation) -> ([VNHumanBodyPoseObservation.JointName: CGPoint]) {
    var joints = [VNHumanBodyPoseObservation.JointName: CGPoint]()
    guard let identifiedPoints = try? observation.recognizedPoints(VNHumanBodyPoseObservation.JointsGroupName.all) else {
        return joints
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        joints[key] = point.location
    }
    
    return joints
}
