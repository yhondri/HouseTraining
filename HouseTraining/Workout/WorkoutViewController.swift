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
import SwiftUI

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var workoutInfoContentView: UIView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var actionQualityLabel: UILabel!
    
    private var timer: Timer?
    private var countDown: Double = 0.0
    private var isCounDownRunning = false
    
    // Live camera feed management
    private(set) var cameraFeedView: CameraFeedView!
    private let viewModel = WorkoutViewModel(actions: [.jumpingJacks, .jumpingJacks])
    //Views
    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView = JointSegmentView()
    private var cancellables = [AnyCancellable]()
    
    init() {
        super.init(nibName: "WorkoutViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.playerRequest.sink { result in
            self.updateHumanBodyPose(reconizedPointsObservation: result)
        }
        .store(in: &cancellables)
        
        viewModel.userActionRequest.sink { action in
            self.updateCurrentActivity(action: action)
        }
        .store(in: &cancellables)
        
        do {
            try viewModel.setupAVSession(avcaptureVideoDataOutputSampleBufferDelegate: self)
            setupCameraFeedSession()
            setUIElements()
        } catch {
            debugPrint("Show error, session couldn't be started ", error)
        }
        
        updateCurrentActivity(action: Action())
        
        workoutInfoContentView.layer.cornerRadius = 12
        workoutInfoContentView.layer.masksToBounds = true
        view.sendSubviewToBack(cameraFeedView)
        
        let pauseGesture = UITapGestureRecognizer(target: self, action: #selector(onChangeActivityState))
        view.addGestureRecognizer(pauseGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let maskOrientation: UIInterfaceOrientationMask
        let interfaceOrientation: UIInterfaceOrientation
        
        super.viewWillAppear(animated)
        if viewModel.orientation == .right {
            maskOrientation = .portrait
            interfaceOrientation = .portrait
        } else {
            maskOrientation = .landscapeRight
            interfaceOrientation = .landscapeRight
        }
        
        AppUtility.lockOrientation(maskOrientation, andRotateTo: interfaceOrientation)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    private func updateCurrentActivity(action: Action) {
        if action.type == .none {
            actionQualityLabel.isHidden = true
            currentActivityLabel.text = "\(LocalizableKey.resting.localized)"
        } else {
            actionQualityLabel.isHidden = false
            currentActivityLabel.text = viewModel.getActionName(action: action.type)
            actionQualityLabel.text = "\(LocalizableKey.quality.localized): \(Int(action.probability))%"
        }
    }
    
    @objc private func onChangeActivityState() {
        if isCounDownRunning {
            pauseActivity()
        } else {
           onResumeActivity()
        }
    }
    
    private func onResumeActivity() {
        invalidateTimer()
        
        countDown = viewModel.currentCountDown
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateCountDown),
                                     userInfo: nil, repeats: true)
        
        viewModel.onResumeActivityDetection()
        
        isCounDownRunning = true
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        isCounDownRunning = false
    }
    
    @objc private func pauseActivity() {
        invalidateTimer()
        viewModel.currentCountDown = countDown
    }
    
    @objc private func updateCountDown() {
        if(countDown > 0) {
            countDown -= 1
            timerLabel.text = String(countDown)
        } else {
            onEndActivity()
        }
    }
        
    private func onEndActivity() {
        pauseActivity()
        viewModel.onEndActivityDetection()
        
        if viewModel.didFinishRoutine {
            showSummaryView()
        } else {
            onResumeActivity()
        }
    }
    
    private func showSummaryView() {
        let workoutSummary = viewModel.getSummaryData()
        let workoutSummaryView = WorkoutSummaryView(workoutSummary: workoutSummary)
        let hostingController = UIHostingController(rootView: workoutSummaryView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func updateHumanBodyPose(reconizedPointsObservation: VNHumanBodyPoseObservation) {
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
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        view.addSubview(playerBoundingBox)
        view.addSubview(jointSegmentView)
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
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: viewModel.cameraFeedSession!, videoOrientation: viewModel.sessionVideoOrientation)
        
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
        
        return box
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension WorkoutViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
                        
        viewModel.cameraViewController(self, didReceiveBuffer: sampleBuffer)
    }
}
