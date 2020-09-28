//
//  WorkoutViewModel.swift
//  HouseTraining
//
//  Created by Yhondri on 22/09/2020.
//

import Dispatch
import AVFoundation
import Vision
import Combine

class WorkoutViewModel: NSObject {
    let videoDataOutputQueue: DispatchQueue
    let playerRequest = PassthroughSubject<VNRecognizedPointsObservation, Never>()

    private let gameManager: ExerciseManager = ExerciseManager()
    private(set) var cameraFeedSession: AVCaptureSession?
    private(set) var displayLink: CADisplayLink?
    private(set) var playerDetected = false
    var currentCountDown = 30.0
    var detectPlayerActivity: Bool = false

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
}

// MARK: CameraOuput manager
extension WorkoutViewModel {
    func cameraViewController(_ controller: WorkoutViewController,
                              didReceiveBuffer buffer: CMSampleBuffer,
                              orientation: CGImagePropertyOrientation) {
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
        //        if !(self.trajectoryInFlightPoseObservations >= GameConstants.maxTrajectoryInFlightPoseObservations) {
        do {
            try visionHandler.perform([detectPlayerRequest])
            //                debugPrint("Body detected ", detectPlayerRequest.results)
            
            if let observation = detectPlayerRequest.results?.first {
                playerRequest.send(observation)
                
                guard detectPlayerActivity else {
                    return
                }

                detectPose(observation: observation)
//                if !playerDetected {
//                    gameManager.stateMachine.enter(DetectedPlayerState.self)
//                }
            }
            //                else {
            //                    debugPrint("Else result detect player")
            //                }
        } catch {
            //                AppError.display(error, inViewController: self)
        }
        //        } else {
        //            // Hide player bounding box
        //            DispatchQueue.main.async {
        //                if !self.playerBoundingBox.isHidden {
        //                    self.playerBoundingBox.isHidden = true
        ////                    self.jointSegmentView.resetView()
        //                }
        //            }
        //        }
    }
    
    private func detectPose(observation: VNRecognizedPointsObservation) {
        self.playerStats.storeObservation(observation)
        self.posesCount += 1
        
        debugPrint("Detect pose", self.posesCount)
        
        if self.posesCount >= self.posesNeeded {
            //                debugPrint("posesCount insede", posesCount)
            
            let throwType = self.playerStats.getLastThrowType()
            //                    debugPrint("ThrowType", throwType)
            
            self.lastThrowMetrics.updateThrowType(throwType)
            self.posesCount -= 1
        }
    }
}
