//
//  ExerciseSetupViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 11/8/20.
//

import Dispatch
import AVFoundation

public class CameraViewModel {
    let gameManager = ExerciseManager.shared
    let videoDataOutputQueue: DispatchQueue
    var cameraFeedSession: AVCaptureSession?
    var displayLink: CADisplayLink?
    
    init() {
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
    
    func captureOutput() {
        if gameManager.stateMachine.currentState is SetupCameraState {
            // Once we received first buffer we are ready to proceed to the next state
            gameManager.stateMachine.enter(DetectedPlayerState.self)
        }
    }
}
