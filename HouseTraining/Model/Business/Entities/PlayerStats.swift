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

enum Scoring: Int {
    case zero = 0
    case one = 1
    case three = 3
    case five = 5
    case fifteen = 15
}

struct PlayerStats {
    var totalScore = 0
    var throwCount = 0
    var topSpeed = 0.0
    var avgSpeed = 0.0
    var releaseAngle = 0.0
    var avgReleaseAngle = 0.0
    private var poseObservations = [VNRecognizedPointsObservation]()
    
    var throwPaths = [CGPath]()
    
    init() {
        debugPrint("Init called")
    }
    
    
    mutating func reset() {
        topSpeed = 0
        avgSpeed = 0
        totalScore = 0
        throwCount = 0
        releaseAngle = 0
//        poseObservations = []
    }

    mutating func adjustMetrics(score: Scoring, speed: Double, releaseAngle: Double, throwType: ActionType) {
        throwCount += 1
        totalScore += score.rawValue
        avgSpeed = (avgSpeed * Double(throwCount - 1) + speed) / Double(throwCount)
        avgReleaseAngle = (avgReleaseAngle * Double(throwCount - 1) + releaseAngle) / Double(throwCount)
        if speed > topSpeed {
            topSpeed = speed
        }
    }

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNRecognizedPointsObservation) {
        if poseObservations.count >= GameConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getReleaseAngle() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightElbow, rightWrist) = armJoints(for: observation)
            // Release angle is computed by measuring the angle forearm (elbow to wrist) makes with the horizontal
               releaseAngle = rightElbow.angleFromHorizontal(to: rightWrist)
        }
        return releaseAngle
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
        
        guard let actionType = ActionType(rawValue: predictions.label.capitalized) else {
            return Action()
        }

//        debugPrint("throwType ", actionType, predictions.labelProbabilities)

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

struct GameConstants {
    static let maxThrows = 8
    static let newGameTimer = 5
    static let boardLength = 1.22
    static let trajectoryLength = 15
    // minimumObjectSize is calculated as (radius of object to be detected / buffer width)
    static let minimumObjectSize = Float(6.0 / 1920)
    static let maxPoseObservations = 60
    static let noObservationFrameLimit = 20
    static let maxDistanceWithCurrentTrajectory: CGFloat = 250
    static let maxTrajectoryInFlightPoseObservations = 10
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


let jointsOfInterest: [VNHumanBodyPoseObservation.JointName] = [.rightWrist,
                                                                .rightElbow,
                                                                .rightShoulder,
                                                                .rightHip,
                                                                .rightKnee,
                                                                .rightAnkle,
                                                                .leftWrist,
                                                                .leftElbow,
                                                                .leftShoulder,
                                                                .leftHip,
                                                                .leftKnee,
                                                                .leftAnkle
]

let humanBodyPoseJoinNameTranslator: [VNRecognizedPointKey: VNHumanBodyPoseObservation.JointName] = [
    VNRecognizedPointKey.bodyLandmarkKeyRightWrist: VNHumanBodyPoseObservation.JointName.rightWrist,
    VNRecognizedPointKey.bodyLandmarkKeyLeftWrist: VNHumanBodyPoseObservation.JointName.leftWrist,
    VNRecognizedPointKey.bodyLandmarkKeyRightElbow: VNHumanBodyPoseObservation.JointName.rightElbow,
    VNRecognizedPointKey.bodyLandmarkKeyLeftElbow: VNHumanBodyPoseObservation.JointName.leftElbow,
    VNRecognizedPointKey.bodyLandmarkKeyRightShoulder: VNHumanBodyPoseObservation.JointName.rightShoulder,
    VNRecognizedPointKey.bodyLandmarkKeyLeftShoulder: VNHumanBodyPoseObservation.JointName.leftShoulder,
    VNRecognizedPointKey.bodyLandmarkKeyRightHip: VNHumanBodyPoseObservation.JointName.rightHip,
    VNRecognizedPointKey.bodyLandmarkKeyLeftHip: VNHumanBodyPoseObservation.JointName.leftHip,
    VNRecognizedPointKey.bodyLandmarkKeyRightKnee: VNHumanBodyPoseObservation.JointName.rightKnee,
    VNRecognizedPointKey.bodyLandmarkKeyLeftKnee: VNHumanBodyPoseObservation.JointName.leftKnee,
    VNRecognizedPointKey.bodyLandmarkKeyRightAnkle: VNHumanBodyPoseObservation.JointName.rightAnkle,
    VNRecognizedPointKey.bodyLandmarkKeyLeftAnkle: VNHumanBodyPoseObservation.JointName.leftAnkle
]

func armJoints(for observation: VNRecognizedPointsObservation) -> (CGPoint, CGPoint) {
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightWrist = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
        return (rightElbow, rightWrist)
    }
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        guard let mKey = humanBodyPoseJoinNameTranslator[key] else { continue }
        
        switch mKey {
        case .rightElbow:
            rightElbow = point.location
        case .rightWrist:
            rightWrist = point.location
        default:
            break
        }
    }
    return (rightElbow, rightWrist)
}

func getBodyJointsFor(observation: VNRecognizedPointsObservation) -> ([VNHumanBodyPoseObservation.JointName: CGPoint]) {
    var joints = [VNHumanBodyPoseObservation.JointName: CGPoint]()
    guard let identifiedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
        return joints
    }
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        guard let mKey = humanBodyPoseJoinNameTranslator[key] else { continue }
        
        if jointsOfInterest.contains(mKey) {
            joints[mKey] = point.location
        }
    }
    return joints
}

// MARK: - Helper extensions

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
    func angleFromHorizontal(to point: CGPoint) -> Double {
        let angle = atan2(point.y - y, point.x - x)
        let deg = abs(angle * (180.0 / CGFloat.pi))
        return Double(round(100 * deg) / 100)
    }
}

extension CGAffineTransform {
    static var verticalFlip = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    static var horizontalFlip = CGAffineTransform(rotationAngle: CGFloat.pi/2).translatedBy(x: 0, y: -1)    
}

extension UIBezierPath {
    convenience init(cornersOfRect borderRect: CGRect, cornerSize: CGSize, cornerRadius: CGFloat) {
        self.init()
        let cornerSizeH = cornerSize.width
        let cornerSizeV = cornerSize.height
        // top-left
        move(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerSizeV + cornerRadius))
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi,
               endAngle: -CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.minY))
        // top-right
        move(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.minY))
        addLine(to: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: -CGFloat.pi / 2,
               endAngle: 0,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.minY + cornerSizeV + cornerRadius))
        // bottom-right
        move(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerSizeV - cornerRadius))
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: 0,
               endAngle: CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.maxY))
        // bottom-left
        move(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.maxY))
        addLine(to: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.maxY))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius,
                                   y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi / 2,
               endAngle: CGFloat.pi,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.maxY - cornerSizeV - cornerRadius))
    }
}
