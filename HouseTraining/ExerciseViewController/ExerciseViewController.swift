//
//  ExerciseViewController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit
import Vision
import AVFoundation

class ExerciseViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let gameManager = GameManager.shared
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    private var playerDetected = false
    
    //Views
    private let playerBoundingBox = BoundingBoxView()
    
    //VNConfidence
    private let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    private let trajectoryDetectionMinConfidence: VNConfidence = 0.9
    private let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1
    
    //Counters
    private var noObservationFrameCount = 0
    private var trajectoryInFlightPoseObservations = 0
    
    //Queue
    private let trajectoryQueue = DispatchQueue(label: "com.ActionAndVision.trajectory", qos: .userInteractive)
    
    //Variables - KPIs
    var lastThrowMetrics: ThrowMetrics {
        get {
            return gameManager.lastThrowMetrics
        }
        set {
            gameManager.lastThrowMetrics = newValue
        }
    }

    var playerStats: PlayerStats {
        get {
            return gameManager.playerStats
        }
        set {
            gameManager.playerStats = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
//        showSummaryGesture = UITapGestureRecognizer(target: self, action: #selector(handleShowSummaryGesture(_:)))
//        showSummaryGesture.numberOfTapsRequired = 2
//        view.addGestureRecognizer(showSummaryGesture)
        
        self.gameManager.stateMachine.enter(TrackThrowsState.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        gameStatusLabel.perform(transition: .fadeIn, duration: 0.25)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        detectTrajectoryRequest = nil
    }
    
    func setUIElements() {
//        resetKPILabels()
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        playerBoundingBox.isHidden = true
        view.addSubview(playerBoundingBox)
//        view.addSubview(jointSegmentView)
//        view.addSubview(trajectoryView)
//        gameStatusLabel.text = "Waiting for player"
//        // Set throw type counters
//        underhandThrowView.throwType = .underhand
//        overhandThrowView.throwType = .overhand
//        underlegThrowView.throwType = .underleg
//        scoreLabel.attributedText = getScoreLabelAttributedStringForScore(0)
    }

    func updateBoundingBox(_ boundingBox: BoundingBoxView, withRect rect: CGRect?) {
        // Update the frame for player bounding box
        boundingBox.frame = rect ?? .zero
        boundingBox.perform(transition: (rect == nil ? .fadeOut : .fadeIn), duration: 0.1)
    }

    func humanBoundingBox(for observation: VNRecognizedPointsObservation) -> CGRect {
        var box = CGRect.zero
        var normalizedBoundingBox = CGRect.null
        // Process body points only if the confidence is high.
        guard observation.confidence > bodyPoseDetectionMinConfidence, let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return box
        }
        // Only use point if human pose joint was detected reliably.
        for (_, point) in points where point.confidence > bodyPoseRecognizedPointMinConfidence {
            normalizedBoundingBox = normalizedBoundingBox.union(CGRect(origin: point.location, size: .zero))
        }
        if !normalizedBoundingBox.isNull {
            box = normalizedBoundingBox
        }
//        // Fetch body joints from the observation and overlay them on the player.
//        let joints = getBodyJointsFor(observation: observation)
//        DispatchQueue.main.async {
//            self.jointSegmentView.joints = joints
//        }
        // Store the body pose observation in playerStats when the game is in TrackThrowsState.
        // We will use these observations for action classification once the throw is complete.
        if gameManager.stateMachine.currentState is TrackThrowsState {
            playerStats.storeObservation(observation)
//            if trajectoryView.inFlight {
//                trajectoryInFlightPoseObservations += 1
//            }
        }
        return box
    }
    
    private func detectPose() {
        // Perform the trajectory request in a separate dispatch queue.
                trajectoryQueue.async {
                    let throwType = self.playerStats.getLastThrowType()
                    debugPrint("ThrowType", throwType)

                    self.lastThrowMetrics.updateThrowType(throwType)

    //                self.detectTrajectoryRequest.minimumObjectSize = GameConstants.minimumObjectSize
    //                do {
    //                    try visionHandler.perform([self.detectTrajectoryRequest])
    //                    if let results = self.detectTrajectoryRequest.results as? [VNTrajectoryObservation] {
    //                        DispatchQueue.main.async {
    //                            self.processTrajectoryObservations(controller, results)
    //                        }
    //                    }
    //                } catch {
    //                    AppError.display(error, inViewController: self)
    //                }
                }
    }
}

extension ExerciseViewController: CameraViewControllerOutputDelegate {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: orientation, options: [:])
//        if gameManager.stateMachine.currentState is TrackThrowsState {
//            DispatchQueue.main.async {
//                // Get the frame of rendered view
//                let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
//                self.jointSegmentView.frame = controller.viewRectForVisionRect(normalizedFrame)
//                self.trajectoryView.frame = controller.viewRectForVisionRect(normalizedFrame)
//            }
//
//        }
        // Body pose request is performed on the same camera queue to ensure the highlighted joints are aligned with the player.
        // Run bodypose request for additional GameConstants.maxPostReleasePoseObservations frames after the first trajectory observation is detected.
        /**self.trajectoryView.inFlight && **/
        if !(self.trajectoryInFlightPoseObservations >= GameConstants.maxTrajectoryInFlightPoseObservations) {
            do {
                try visionHandler.perform([detectPlayerRequest])
                if let result = detectPlayerRequest.results?.first as? VNRecognizedPointsObservation {
                    let box = humanBoundingBox(for: result)
                    let boxView = playerBoundingBox
                    DispatchQueue.main.async {
                        let inset: CGFloat = -20.0
                        let viewRect = controller.viewRectForVisionRect(box).insetBy(dx: inset, dy: inset)
                        self.updateBoundingBox(boxView, withRect: viewRect)
                        if !self.playerDetected && !boxView.isHidden {
                            //                            self.gameStatusLabel.alpha = 0
                            //                            self.resetTrajectoryRegions()
                            self.gameManager.stateMachine.enter(DetectedPlayerState.self)
                        }
                        
                        self.detectPose()

                    }
                    
                }
            } catch {
                AppError.display(error, inViewController: self)
            }
        } else {
            // Hide player bounding box
            DispatchQueue.main.async {
                if !self.playerBoundingBox.isHidden {
                    self.playerBoundingBox.isHidden = true
//                    self.jointSegmentView.resetView()
                }
            }
        }
    }
}


extension ExerciseViewController: GameStateChangeObserver {
    func gameManagerDidEnter(state: State, from previousState: State?) {
        switch state {
        case is DetectedPlayerState:
            playerDetected = true
            playerStats.reset()
//            playerBoundingBox.perform(transition: .fadeOut, duration: 1.0)
//            gameStatusLabel.text = "Go"
//            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
                self.gameManager.stateMachine.enter(TrackThrowsState.self)
//            }
        case is TrackThrowsState:
            break
//            resetTrajectoryRegions()
//            trajectoryView.roi = throwRegion
        case is ThrowCompletedState:
//            dashboardView.speed = lastThrowMetrics.releaseSpeed
//            dashboardView.animateSpeedChart()
            playerStats.adjustMetrics(score: lastThrowMetrics.score, speed: lastThrowMetrics.releaseSpeed,
                                      releaseAngle: lastThrowMetrics.releaseAngle, throwType: lastThrowMetrics.throwType)
            playerStats.resetObservations()
            trajectoryInFlightPoseObservations = 0
//            self.updateKPILabels()
//
//            gameStatusLabel.text = lastThrowMetrics.score.rawValue > 0 ? "+\(lastThrowMetrics.score.rawValue)" : ""
//            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
//                if self.playerStats.throwCount == GameConstants.maxThrows {
//                    self.gameManager.stateMachine.enter(GameManager.ShowSummaryState.self)
//                } else {
//                    self.gameManager.stateMachine.enter(GameManager.TrackThrowsState.self)
//                }
//            }
        default:
            break
        }
    }
}
