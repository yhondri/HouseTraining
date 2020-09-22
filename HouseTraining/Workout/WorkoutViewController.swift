//
//  WorkoutViewController.swift
//  HouseTraining
//
//  Created by Yhondri on 22/09/2020.
//

import UIKit
import AVFoundation
import Vision
import Combine

class WorkoutViewController: UIViewController {
    
    // Live camera feed management
    private(set) var cameraFeedView: CameraFeedView!
    private let viewModel = WorkoutViewModel()
    //Views
    private let playerBoundingBox = BoundingBoxView()
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.playerRequest.sink { result in
            self.updateHumanBodyPose(reconizedPointsObservation: result)
        }
        .store(in: &cancellables)
        
        do {
            try viewModel.setupAVSession(avcaptureVideoDataOutputSampleBufferDelegate: self)
            setupCameraFeedSession()
            setUIElements()            
        } catch {
            debugPrint("Show error, session couldn't be started ", error)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()
    }
    
    private func updateHumanBodyPose(reconizedPointsObservation: VNRecognizedPointsObservation) {
        let box = humanBoundingBox(for: reconizedPointsObservation)
        let boxView = playerBoundingBox
        DispatchQueue.main.async {
            let inset: CGFloat = -20.0
            let viewRect = VisionHelper.viewRectForVisionRect(box, cameraFeedView: self.cameraFeedView).insetBy(dx: inset, dy: inset)
            self.updateBoundingBox(boxView, withRect: viewRect)
//            if !self.playerDetected && !boxView.isHidden {
//                //                            self.gameStatusLabel.alpha = 0
//                //                            self.resetTrajectoryRegions()
//                self.gameManager.stateMachine.enter(DetectedPlayerState.self)
//            }
            
//            self.detectPose(observation: result)
        }
    }
}

// MARK: - BoundingBox
extension WorkoutViewController {
    func setUIElements() {
//        resetKPILabels()
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        playerBoundingBox.isHidden = true
        view.addSubview(playerBoundingBox)
        view.bringSubviewToFront(playerBoundingBox)
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
}

// MARK: - Camera setup
extension WorkoutViewController {
    private func setupCameraFeedSession() {
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation = getVideoOrientation()
        
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: viewModel.cameraFeedSession!, videoOrientation: videoOrientation)
        setupVideoOutputView(cameraFeedView)
        viewModel.cameraFeedSession!.startRunning()
    }
    
    private func getVideoOrientation() -> AVCaptureVideoOrientation {
        if UIDevice.current.orientation.isLandscape {
            return .landscapeRight
        } else {
            return .portrait
        }
    }
    
    private func setupVideoOutputView(_ videoOutputView: UIView) {
        videoOutputView.translatesAutoresizingMaskIntoConstraints = false
        videoOutputView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.addSubview(videoOutputView)
        NSLayoutConstraint.activate([
            videoOutputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoOutputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoOutputView.topAnchor.constraint(equalTo: view.topAnchor),
            videoOutputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func humanBoundingBox(for observation: VNRecognizedPointsObservation) -> CGRect {
        var box = CGRect.zero
        var normalizedBoundingBox = CGRect.null
        // Process body points only if the confidence is high.
        guard observation.confidence > viewModel.bodyPoseDetectionMinConfidence,
              let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return box
        }
        
        // Only use point if human pose joint was detected reliably.
        for (_, point) in points where point.confidence > viewModel.bodyPoseRecognizedPointMinConfidence {
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
//        if gameManager.stateMachine.currentState is TrackThrowsState {
//            debugPrint("StoreObservation    ")
//            playerStats.storeObservation(observation)
////            if trajectoryView.inFlight {
////                trajectoryInFlightPoseObservations += 1
////            }
//        }
        return box
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension WorkoutViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        viewModel.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: .up)
        DispatchQueue.main.async {
            self.viewModel.captureOutput()
        }
    }
}
