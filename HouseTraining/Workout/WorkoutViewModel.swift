//
//  WorkoutViewModel.swift
//  HouseTraining
//
//  Created by Yhondri on 22/09/2020.
//

import UIKit
import Dispatch
import AVFoundation
import Vision
import Combine

class WorkoutViewModel: NSObject {
    let videoDataOutputQueue: DispatchQueue
    let playerRequest = PassthroughSubject<VNRecognizedPointsObservation, Never>()
    let userActionRequest = PassthroughSubject<Action, Never>()

    
    private let gameManager: ExerciseManager = ExerciseManager()
    private(set) var cameraFeedSession: AVCaptureSession?
    private(set) var displayLink: CADisplayLink?
    private(set) var playerDetected = false
    var currentCountDown = 30.0
    var detectPlayerActivity: Bool = false
    ///  .upMirrored = LandscapeLeft. .right = Potrait camera top.
    let orientation: CGImagePropertyOrientation = .right
    let sessionVideoOrientation: AVCaptureVideoOrientation
    ///Nos permite separar las llamadas para detectar la acción actual del usuario. En consejos para mejorar la eficiencia de la acción realizada por el usuario, los ingenieros de Apple aconsejan no hacer llamadas demasiadas veces seguidas.
    private var detectActionTimer: Timer?

    //Vision
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    //VNConfidence
    let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    let trajectoryDetectionMinConfidence: VNConfidence = 0.9
    let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1

    //Counters
    private var noObservationFrameCount = 0
    private var trajectoryInFlightPoseObservations = 0
    private var posesNeeded = 60
    private var posesCount = 0
    
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
    
    override init() {
        videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput",
                                             qos: .userInitiated,
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
        
        if orientation == .right {
            sessionVideoOrientation = .portrait
        } else {
            sessionVideoOrientation = .landscapeRight
        }
    }
    
    func viewDidDissapear() {
        // Stop capture session if it's running
        cameraFeedSession?.stopRunning()
        // Invalidate display link so it's removed from run loop
        displayLink?.invalidate()
    }
    
    func captureOutput() {
        if gameManager.stateMachine.currentState is SetupCameraState {
            // Once we received first buffer we are ready to proceed to the next state
            gameManager.stateMachine.enter(DetectedPlayerState.self)
        }
    }
    
    func setupAVSession(avcaptureVideoDataOutputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) throws {
        // Create device discovery session for a wide angle camera
        let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [wideAngle], mediaType: .video, position: .unspecified)
        
        // Select a video device, make an input
        guard let videoDevice = discoverySession.devices.first else {
            throw AppError.captureSessionSetup(reason: "Could not find a wide angle camera device.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        // We prefer a 1080p video capture but if camera cannot provide it then fall back to highest possible quality
        if videoDevice.supportsSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        } else {
            session.sessionPreset = .high
        }
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(avcaptureVideoDataOutputSampleBufferDelegate, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        
        let captureConnection = dataOutput.connection(with: .video)
        captureConnection?.preferredVideoStabilizationMode = .standard
        // Always process the frames
        captureConnection?.isEnabled = true
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func onEndActivity() {
        
    }
        
    private func onResumeActivity() {
        invalidateTimer()
        
        guard detectActionTimer == nil else { return }
        
        DispatchQueue.main.async {
            self.detectActionTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                          target: self,
                                                          selector: #selector(self.detectAction),
                                                          userInfo: nil,
                                                          repeats: true)
        }
    }
    
    private func invalidateTimer() {
        guard detectActionTimer != nil else { return }
        DispatchQueue.main.async {
            self.detectActionTimer?.invalidate()
            self.detectActionTimer = nil
        }
    }
}

// MARK: CameraOuput manager
extension WorkoutViewModel {
    func cameraViewController(_ controller: WorkoutViewController,
                              didReceiveBuffer buffer: CMSampleBuffer) {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: orientation, options: [:])
        
        do {
            try visionHandler.perform([detectPlayerRequest])
            
            if let observation = detectPlayerRequest.results?.first {
                playerRequest.send(observation)
                
                guard detectPlayerActivity else {
                    DispatchQueue.main.async {
                        self.invalidateTimer()
                    }
                    return
                }
                
                if detectActionTimer == nil {
                    self.onResumeActivity()
                }

                storeObservation(observation)
            }
        } catch {
           debugPrint("Error - WorkoutViewModel - camera(...): ", error)
        }
    }
    
    private func storeObservation(_ observation: VNRecognizedPointsObservation) {
        if observation.confidence > bodyPoseDetectionMinConfidence {
            self.playerStats.storeObservation(observation)
            self.posesCount += 1
        }
    }
    
    @objc private func detectAction() {
        ///Confidence to score quality of action
        let currentAction = self.playerStats.getAction()
        userActionRequest.send(currentAction)
//        self.lastThrowMetrics.updateThrowType(throwType)
    }
}
