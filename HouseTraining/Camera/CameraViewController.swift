//
//  CameraViewController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit
import AVFoundation

protocol CameraViewControllerOutputDelegate: class {
    func cameraViewController(_ controller: CameraViewController,
                              didReceiveBuffer buffer: CMSampleBuffer,
                              orientation: CGImagePropertyOrientation)
}

class CameraViewController: UIViewController {
    
    private let gameManager = GameManager.shared
    weak var outputDelegate: CameraViewControllerOutputDelegate?
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput",
                                                     qos: .userInitiated,
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)
    
    // Live camera feed management
    private var cameraFeedView: CameraFeedView!
    private var cameraFeedSession: AVCaptureSession?

    // Video file playback management
    private var videoRenderView: VideoRenderView!
    private var playerItemOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private let videoFileReadingQueue = DispatchQueue(label: "VideoFileReading", qos: .userInteractive)
    private var videoFileBufferOrientation = CGImagePropertyOrientation.up
    private var videoFileFrameDuration = CMTime.invalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingStateChanges()
    
        try? setupAVSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop capture session if it's running
        cameraFeedSession?.stopRunning()
        // Invalidate display link so it's removed from run loop
        displayLink?.invalidate()
    }
    
    func setupAVSession() throws {
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
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        let captureConnection = dataOutput.connection(with: .video)
        captureConnection?.preferredVideoStabilizationMode = .standard
        // Always process the frames
        captureConnection?.isEnabled = true
        session.commitConfiguration()
        cameraFeedSession = session
        
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation
        switch view.window?.windowScene?.interfaceOrientation {
        case .landscapeRight:
            videoOrientation = .landscapeRight
        default:
            videoOrientation = .portrait
        }
        
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: session, videoOrientation: videoOrientation)
        setupVideoOutputView(cameraFeedView)
        cameraFeedSession?.startRunning()
    }
    
    // This helper function is used to convert rects returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
    func viewRectForVisionRect(_ visionRect: CGRect) -> CGRect {
        let flippedRect = visionRect.applying(CGAffineTransform.verticalFlip)
        let viewRect: CGRect
        if cameraFeedSession != nil {
            viewRect = cameraFeedView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        } else {
            viewRect = videoRenderView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        }
        return viewRect
    }
    
    // This helper function is used to convert points returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
    func viewPointForVisionPoint(_ visionPoint: CGPoint) -> CGPoint {
        let flippedPoint = visionPoint.applying(CGAffineTransform.verticalFlip)
        let viewPoint: CGPoint
        if cameraFeedSession != nil {
            viewPoint = cameraFeedView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        } else {
            viewPoint = videoRenderView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        }
        return viewPoint
    }

    func setupVideoOutputView(_ videoOutputView: UIView) {
        videoOutputView.translatesAutoresizingMaskIntoConstraints = false
        videoOutputView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(videoOutputView)
        NSLayoutConstraint.activate([
            videoOutputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoOutputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoOutputView.topAnchor.constraint(equalTo: view.topAnchor),
            videoOutputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        guard let output = playerItemOutput else {
            return
        }
        
        videoFileReadingQueue.async {
            let nextTimeStamp = displayLink.timestamp + displayLink.duration
            let itemTime = output.itemTime(forHostTime: nextTimeStamp)
            guard output.hasNewPixelBuffer(forItemTime: itemTime) else {
                return
            }
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
                return
            }
            // Create sample buffer from pixel buffer
            var sampleBuffer: CMSampleBuffer?
            var formatDescription: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
            let duration = self.videoFileFrameDuration
            var timingInfo = CMSampleTimingInfo(duration: duration, presentationTimeStamp: itemTime, decodeTimeStamp: itemTime)
            CMSampleBufferCreateForImageBuffer(allocator: nil,
                                               imageBuffer: pixelBuffer,
                                               dataReady: true,
                                               makeDataReadyCallback: nil,
                                               refcon: nil,
                                               formatDescription: formatDescription!,
                                               sampleTiming: &timingInfo,
                                               sampleBufferOut: &sampleBuffer)
            if let sampleBuffer = sampleBuffer {
                self.outputDelegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: self.videoFileBufferOrientation)
                DispatchQueue.main.async {
                    let stateMachine = self.gameManager.stateMachine
                    if stateMachine.currentState is SetupCameraState {
                        // Once we received first buffer we are ready to proceed to the next state
                        stateMachine.enter(DetectedPlayerState.self)
                    }
                }
            }
        }
    }
}


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        outputDelegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: .up)
        
        DispatchQueue.main.async {
            let stateMachine = self.gameManager.stateMachine
            if stateMachine.currentState is SetupCameraState {
                // Once we received first buffer we are ready to proceed to the next state
                stateMachine.enter(DetectedPlayerState.self)
            }
        }
    }
}

extension CameraViewController: GameStateChangeObserver {
    func gameManagerDidEnter(state: State, from previousState: State?) {
        if state is SetupCameraState {
            do {
//                if let video = gameManager.recordedVideoSource {
//                    startReadingAsset(video)
//                } else {
                    try setupAVSession()
//                }
            } catch {
                AppError.display(error, inViewController: self)
            }
        }
    }
}
