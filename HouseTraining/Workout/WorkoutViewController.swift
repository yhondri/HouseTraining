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
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var workoutInfoContentView: UIView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    
    private var timer: Timer?
    private var countDown: Double = 0.0
    
    // Live camera feed management
    private(set) var cameraFeedView: CameraFeedView!
    private let viewModel = WorkoutViewModel()
    //Views
    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView = JointSegmentView()
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
        
        workoutInfoContentView.layer.cornerRadius = 12
        workoutInfoContentView.layer.masksToBounds = true
        view.sendSubviewToBack(cameraFeedView)
        
        let pauseGesture = UITapGestureRecognizer(target: self, action: #selector(onChangeActivityState))
        view.addGestureRecognizer(pauseGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let videoOrientation: AVCaptureVideoOrientation = getVideoOrientation()
        cameraFeedView.changeVideoOrientation(newOrientation: videoOrientation)
    }
    
    @objc private func onChangeActivityState() {
        if viewModel.detectPlayerActivity {
            pauseActivity()
        } else {
           onResumeActivity()
        }
    }
    
    private func onResumeActivity() {
        viewModel.detectPlayerActivity = true
        invalidateTimer()
        
        countDown = viewModel.currentCountDown
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateCountDown),
                                     userInfo: nil, repeats: true)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func pauseActivity() {
        invalidateTimer()
        viewModel.detectPlayerActivity = false
        viewModel.currentCountDown = countDown
    }
    
    @objc private func updateCountDown() {
        if(countDown > 0) {
            countDown -= 1
            timerLabel.text = String(countDown)
        } else {
//            onEndActivity()
        }
    }
        
    private func onEndActivity() {
        pauseActivity()
        viewModel.onEndActivity()
    }
    
    private func updateHumanBodyPose(reconizedPointsObservation: VNRecognizedPointsObservation) {
        let box = humanBoundingBox(for: reconizedPointsObservation)
        let boxView = playerBoundingBox
        DispatchQueue.main.async {
            let inset: CGFloat = -20.0
            let viewRect = VisionHelper.viewRectForVisionRect(box, cameraFeedView: self.cameraFeedView).insetBy(dx: inset, dy: inset)
            self.updateBoundingBox(boxView, withRect: viewRect)
            
            // Fetch body joints from the observation and overlay them on the player.
            let joints = getBodyJointsFor(observation: reconizedPointsObservation)
            self.jointSegmentView.joints = joints
            
            let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
            self.jointSegmentView.frame = VisionHelper.viewRectForVisionRect(normalizedFrame, cameraFeedView: self.cameraFeedView)
        }
    }
}

// MARK: - BoundingBox
extension WorkoutViewController {
    func setUIElements() {
//        resetKPILabels()
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
//        playerBoundingBox.isHidden = true
        view.addSubview(playerBoundingBox)
        view.addSubview(jointSegmentView)

        //        view.addSubview(trajectoryView)
//        gameStatusLabel.text = "Waiting for player"
//        // Set throw type counters
//        underhandThrowView.throwType = .underhand
//        overhandThrowView.throwType = .overhand
//        underlegThrowView.throwType = .underleg
//        scoreLabel.attributedText = getScoreLabelAttributedStringForScore(0)
    }

    func updateBoundingBox(_ view: UIView, withRect rect: CGRect?) {
        // Update the frame for player bounding box
        view.frame = rect ?? .zero
        
        if let view = view as? AnimatedTransitioning {
            view.perform(transition: (rect == nil ? .fadeOut : .fadeIn), duration: 0.1)
        }
    }
}

// MARK: - Camera setup
extension WorkoutViewController {
    private func setupCameraFeedSession() {
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation = getVideoOrientation()
        debugPrint("setupCameraFeedSession ", videoOrientation)
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: viewModel.cameraFeedSession!, videoOrientation: videoOrientation)
        
        cameraFeedView.translatesAutoresizingMaskIntoConstraints = false
        cameraFeedView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.addSubview(cameraFeedView)
        NSLayoutConstraint.activate([
            cameraFeedView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraFeedView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraFeedView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraFeedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        viewModel.cameraFeedSession!.startRunning()
    }
    
    private func getVideoOrientation() -> AVCaptureVideoOrientation {
        debugPrint("UIDevice.current.orientation.isLandscape ", UIDevice.current.orientation.isLandscape)
        if UIDevice.current.orientation.isLandscape {
            debugPrint("Orientation landscapeRight")
            return .landscapeRight
        } else {
            debugPrint("Orientation portrait")
            return .portrait
        }
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
        
        let orientation = getImageOrientation()
                
        viewModel.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: orientation)
        DispatchQueue.main.async {
        
        }
    }
    
    func getImageOrientation() -> CGImagePropertyOrientation{
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        
        return exifOrientation
    }
}
