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

extension UIView {

    /// Flip view horizontally.
    func flipX() {
        transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
    }

    /// Flip view vertically.
    func flipY() {
        transform = CGAffineTransform(scaleX: transform.a, y: -transform.d)
    }
 }

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var workoutInfoContentView: UIView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var actionQualityLabel: UILabel!
    @IBOutlet var progressBars: [UIProgressView]!
    @IBOutlet weak var noCameraPermissionView: UIView!
    @IBOutlet weak var noCameraPermissionLabel: UILabel!
    @IBOutlet weak var noCameraPermissionButton: UIButton!
    @IBOutlet weak var startTrainingLabel: UILabel!
    @IBOutlet weak var resumeCountDownLabel: UILabel!
    @IBOutlet weak var resumeCountDownMessageLabel: UILabel!
    @IBOutlet weak var resumeCountDownCardView: UIView!
    @IBOutlet weak var resumeCountDownContentView: UIView!
    @IBOutlet weak var resumeCountDownButton: UIButton!
    
    private var resumeTimer: Timer?

    private var timer: Timer?
    private var countDown: Double = 0.0
    private var isCounDownRunning = false
    
    // Live camera feed management
    private(set) var cameraFeedView: CameraFeedView!
    private let viewModel: WorkoutViewModel
    //Views
//    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView: JointSegmentView = {
        let newView = JointSegmentView()
        newView.flipX()
        return newView
    }()
    
    private var cancellables = [AnyCancellable]()
    private var didStartRoutine: Bool = false

    init(viewModel: WorkoutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "WorkoutViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.isCameraAuthorizationGranted.sink { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.onSetupView()
                }
                self?.noCameraPermissionView.isHidden = granted
            }
        }
        .store(in: &cancellables)
        
        viewModel.viewDidLoad()
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
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tool.hiddenTabBar()
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
    
    private func onSetupView() {
        showPauseView()
        
        viewModel.playerRequest.sink { result in
            self.updateHumanBodyPose(reconizedPointsObservation: result)
        }
        .store(in: &cancellables)
        
        viewModel.userActionRequest.sink { action in
            self.updateCurrentActivity(action: action)
        }
        .store(in: &cancellables)
        
        view.addSubview(jointSegmentView)
        viewModel.playerFaceRequest.receive(on: DispatchQueue.main).sink { action in
            self.jointSegmentView.setupBlurFace(faceObservation: action)
        }
        .store(in: &cancellables)
        
        do {
            try viewModel.setupAVSession(avcaptureVideoDataOutputSampleBufferDelegate: self)
            setupCameraFeedSession()
        } catch {
            debugPrint("Show error, session couldn't be started ", error)
        }
        
        for index in 0..<viewModel.numberOfExercises {
            progressBars[index].isHidden = false
        }
        
        updateCurrentActivity(action: Action())
        
        workoutInfoContentView.layer.cornerRadius = 12
        workoutInfoContentView.layer.masksToBounds = true
        view.sendSubviewToBack(cameraFeedView)
        
        let pauseGesture = UITapGestureRecognizer(target: self, action: #selector(onChangeActivityState))
        cameraFeedView.addGestureRecognizer(pauseGesture)

        //ResumeView
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        resumeCountDownButton.setImage(largeBoldDoc, for: .normal)
        resumeCountDownButton.contentMode = .center
        resumeCountDownCardView.layer.cornerRadius = 12
        resumeCountDownCardView.layer.masksToBounds = true
    }
    
    private func updateCurrentActivity(action: Action) {
        if action.type == .none {
            actionQualityLabel.isHidden = true
            currentActivityLabel.text = "\(LocalizableKey.unknownActivity.localized)"
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
        startTrainingLabel.isHidden = isCounDownRunning
    }
    
    private func onResumeActivity() {
        invalidateTimer()
        
        countDown = viewModel.currentCountDown
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateCountDown),
                                     userInfo: nil, repeats: true)
        
        if !didStartRoutine {
            viewModel.isResting = false
            didStartRoutine = true
        }
        
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
        showPauseView()
    }
    
    @objc private func updateCountDown() {
        if(countDown > 0) {
            countDown -= 1
            timerLabel.text = String(countDown)
            if !viewModel.isResting {
                let progress = ((viewModel.initialCountDown - countDown)*100)/viewModel.initialCountDown
                progressBars[viewModel.currentActivityIndex].setProgress(Float(progress/100), animated: true)
            }
        } else {
            onEndActivity()
        }
    }
        
    private func onEndActivity() {
        pauseActivity()
        viewModel.isResting = !viewModel.isResting
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
        guard isCounDownRunning else {
            DispatchQueue.main.async {
                self.jointSegmentView.isHidden = true
            }
            return
        }
        

        DispatchQueue.main.async {
            self.jointSegmentView.isHidden = false
            
            let joints = getBodyJointsFor(observation: reconizedPointsObservation)
            self.jointSegmentView.joints = joints

            let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
            self.jointSegmentView.frame = VisionHelper.viewRectForVisionRect(normalizedFrame, cameraFeedView: self.cameraFeedView)
        }
    }
    
    @IBAction func goToAppSettings(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    
    //MARK: - ResumeCountDown
    private var resumeCountDown: Int = 0
    private let resumeCountDownInitialValue = 7
    
    private func showPauseView() {
        resumeCountDown = resumeCountDownInitialValue
        resumeCountDownLabel.text = "\(resumeCountDown)"
        resumeCountDownLabel.isHidden = true
        resumeCountDownContentView.isHidden = false
        resumeCountDownButton.isHidden = false
        resumeCountDownMessageLabel.text = "Cuando empiece la cuenta atrás aléjate hasta una distancia donde la cámara te capture completamente"
    }
    
    @IBAction func onResume(_ sender: Any) {
        resumeCountDownLabel.isHidden = false
        resumeCountDownButton.isHidden = true
        resumeCountDownMessageLabel.text = "Ya casi estamos, ¿ready?"
        startResumeCountDown()
    }
    
    private func startResumeCountDown() {
        resumeTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateResumeCountDown),
                                     userInfo: nil, repeats: true)
        
        playSound()
    }
    
    @objc private func updateResumeCountDown() {
        resumeCountDown -= 1
        
        if resumeCountDown == 0 {
            resumeCountDownContentView.isHidden = true
            invalidateResumeTimer()
            onChangeActivityState()
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.resumeCountDownLabel.text = "\(self.resumeCountDown)"
            self.resumeCountDownLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }, completion: { done in
            UIView.animate(withDuration: 0.25, animations: {
                self.resumeCountDownLabel.transform = .identity
            }, completion: nil)
        })
        
    }
    
    private func invalidateResumeTimer() {
        resumeTimer?.invalidate()
        resumeTimer = nil
    }
    
    var audioPlayer : AVAudioPlayer?

    
    private func playSound() {
        guard let audioURL = Bundle(for: type(of: self)).url(forResource: "count_down", withExtension: "m4a") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error as NSError {
            debugPrint(error)
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
    
//    func humanBoundingBox(for observation: VNRecognizedPointsObservation) -> CGRect {
//        var box = CGRect.zero
//        var normalizedBoundingBox = CGRect.null
//        // Process body points only if the confidence is high.
//        guard observation.confidence > viewModel.bodyPoseDetectionMinConfidence,
//              let points = try? observation.recognizedPoints(forGroupKey: .all) else {
//            return box
//        }
//
//        // Only use point if human pose joint was detected reliably.
//        for (_, point) in points where point.confidence > viewModel.bodyPoseRecognizedPointMinConfidence {
//            normalizedBoundingBox = normalizedBoundingBox.union(CGRect(origin: point.location, size: .zero))
//        }
//
//        if !normalizedBoundingBox.isNull {
//            box = normalizedBoundingBox
//        }
//
//        return box
//    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension WorkoutViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
                        
        viewModel.cameraViewController(self, didReceiveBuffer: sampleBuffer)
    }
}
