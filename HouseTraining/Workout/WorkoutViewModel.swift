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
    let playerRequest = PassthroughSubject<VNHumanBodyPoseObservation, Never>()
    let userActionRequest = PassthroughSubject<Action, Never>()
    let isCameraAuthorizationGranted = PassthroughSubject<Bool, Never>()

    private(set) var cameraFeedSession: AVCaptureSession?
    private(set) var displayLink: CADisplayLink?
    private(set) var playerDetected = false

    //Vision
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    //VNConfidence
    let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1
    
    private var detectPlayerActivity: Bool = false
    ///  .upMirrored = LandscapeLeft. .right = Potrait camera top.
    let orientation: CGImagePropertyOrientation = .right
    let sessionVideoOrientation: AVCaptureVideoOrientation

    private var noObservationFrameCount = 0
    private var trajectoryInFlightPoseObservations = 0
    private var posesNeeded = 60
    private var posesCount = 0
    ///Nos permite separar las llamadas para detectar la acción actual del usuario. En consejos para mejorar la eficiencia de la acción realizada por el usuario, los ingenieros de Apple aconsejan no hacer llamadas demasiadas veces seguidas.
    private var detectActionTimer: Timer?
    ///Guarda el tiempo restante de la actividad actual en segundos.
    var currentCountDown: Double = 10.0
    ///Define el tiempo de una actividad en segundos.
    let initialCountDown: Double = 10
    var isResting = true
    
    //Variables - KPIs
    private var playerStats = PlayerStats()
    private let actions: [ActionType]
    private lazy var exercises: [Exercise] = createRoutine()
    private(set) var currentActivityIndex = 0
    let numberOfExercises: Int
    
    var didFinishRoutine: Bool {
        currentActivityIndex == exercises.count
    }
    
    init(actions: [ActionType]) {
        self.actions = actions
        numberOfExercises = actions.count
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
    
    func viewDidLoad() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            isCameraAuthorizationGranted.send(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.isCameraAuthorizationGranted.send(true)
                } else {
                    self.isCameraAuthorizationGranted.send(false)
                }
            })
        }
    }
    
    func viewDidDissapear() {
        // Stop capture session if it's running
        cameraFeedSession?.stopRunning()
        // Invalidate display link so it's removed from run loop
        displayLink?.invalidate()
    }
    
    private func createRoutine() -> [Exercise] {
        actions.compactMap { action -> Exercise? in
            switch action {
            case .highKneesRunInPlace:
                return HighKneesRunInPlace()
            case .jumpingJacks:
                return JumpingJacks()
            case .plank:
                return Plank()
            case .sumoSquat:
                return SumoSquat()
            case .wallSit:
                return WallSit()
            default:
                fatalError("Action not implemented")
            }
        }
    }
    
    func getActionName(action: ActionType) -> String {
        switch action {
        case .jumpingJacks:
            return LocalizableKey.jumpingJacks.localized
        default:
            return LocalizableKey.resting.localized
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
        
    func onResumeActivityDetection() {
        invalidateTimer()
        
        guard detectActionTimer == nil else { return }
        
        detectPlayerActivity = true
        
        DispatchQueue.main.async {
            self.detectActionTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                          target: self,
                                                          selector: #selector(self.detectAction),
                                                          userInfo: nil,
                                                          repeats: true)
        }
    }
    
    func onEndActivityDetection() {
        currentCountDown = initialCountDown
        
        if isResting {
            currentActivityIndex += 1
            detectPlayerActivity = false
            userActionRequest.send(Action(type: .none, probability: 100.0))
            
            if didFinishRoutine {
                invalidateTimer()
            }
        } else {
            detectPlayerActivity = true
        }
    }
    
    private func invalidateTimer() {
        guard detectActionTimer != nil else { return }
        DispatchQueue.main.async {
            self.detectActionTimer?.invalidate()
            self.detectActionTimer = nil
        }
    }
    
    func getSummaryData() -> WorkoutSummary {
         WorkoutSummary(duration: 30,
                                            successRate: 95,
                                            heartRate: 123,
                                            caloriesBurned: 222,
                                            exercises: exercises)
    }
}

// MARK: CameraOuput manager
extension WorkoutViewModel {
    func cameraViewController(_ controller: WorkoutViewController,
                              didReceiveBuffer buffer: CMSampleBuffer) {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer,
                                                  orientation: orientation, options: [:])
        
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
                
                storeObservation(observation)
            }
        } catch {
           debugPrint("Error - WorkoutViewModel - camera(...): ", error)
        }
    }
    
    private func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if observation.confidence > bodyPoseDetectionMinConfidence {
            self.playerStats.storeObservation(observation)
            self.posesCount += 1
        }
    }
    
    @objc private func detectAction() {
        guard self.posesCount >= 60 else { return }
        
        ///Confidence to score quality of action
        let currentAction = self.playerStats.getAction()
        userActionRequest.send(currentAction)
        exercises[currentActivityIndex].didDectectAction(action: currentAction)
    }
}
