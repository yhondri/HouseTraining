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
    
    // Live camera feed management
    private(set) var cameraFeedView: CameraFeedView!
    private let viewModel = CameraViewModel()
    weak var outputDelegate: CameraViewControllerOutputDelegate?
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput",
                                                     qos: .userInitiated,
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingStateChanges()
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()
    }
    
    private func setupView() {
        do {
            try viewModel.setupAVSession(avcaptureVideoDataOutputSampleBufferDelegate: self)
        } catch {
            debugPrint("Show error, session couldn't be started ", error)
        }
        
        setupCameraFeedSession()
    }
    
    private func setupCameraFeedSession() {
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation
        switch view.window?.windowScene?.interfaceOrientation {
        case .landscapeRight:
            videoOrientation = .landscapeRight
        default:
            videoOrientation = .portrait
        }
        
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: viewModel.cameraFeedSession!, videoOrientation: videoOrientation)
        setupVideoOutputView(cameraFeedView)
        viewModel.cameraFeedSession!.startRunning()
    }

    private func setupVideoOutputView(_ videoOutputView: UIView) {
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
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        outputDelegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: .up)
        
        DispatchQueue.main.async {
            self.viewModel.captureOutput()
        }
    }
}

extension CameraViewController: ExerciseStateChangeObserver {
    func gameManagerDidEnter(state: State, from previousState: State?) {
        if state is SetupCameraState {
            setupView()
        }
    }
}
