//
//  SetupViewController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit
import Combine

class SetupViewController: UIViewController {
    //    @IBOutlet weak var closeButton: UIButton!
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    override public var shouldAutorotate: Bool {
        return true
    }
    
    private var cameraViewController: CameraViewController!
    private var overlayParentView: UIView!
    private var overlayViewController: UIViewController!
    private let viewModel = SetupViewModel()
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeDeviceOrientation(newOrientation: .landscapeRight, interfaceOrientationMask: .landscapeRight)

        cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        addChild(cameraViewController)
        cameraViewController.beginAppearanceTransition(true, animated: true)
        view.addSubview(cameraViewController.view)
        cameraViewController.endAppearanceTransition()
        cameraViewController.didMove(toParent: self)
        overlayParentView = UIView(frame: view.bounds)
        overlayParentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayParentView)
        NSLayoutConstraint.activate([
            overlayParentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            overlayParentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            overlayParentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            overlayParentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        // Make sure close button stays in front of other views.
        //        view.bringSubviewToFront(closeButton)
        
        viewModel.state.sink { state in
            self.setupOverlayController(forState: state)
        }
        .store(in: &cancellables)
        
        viewModel.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changeDeviceOrientation(newOrientation: .portrait, interfaceOrientationMask: .portrait)
    }

    private func changeDeviceOrientation(newOrientation: UIInterfaceOrientation, interfaceOrientationMask: UIInterfaceOrientationMask) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.myOrientation = interfaceOrientationMask
        UIDevice.current.setValue(newOrientation.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
    }
    
    private func setupOverlayController(forState state: State) {
        // Create an overlay view controller based on the game state
        let controllerToPresent: UIViewController
        switch state {
        //        case is GameManager.DetectingBoardState:
        //            controllerToPresent = SetupViewController()
        case is DetectingPlayerState:
            controllerToPresent = ExerciseViewController()
        //        case is GameManager.ShowSummaryState:
        //            controllerToPresent = SummaryViewController()
        default:
            //The new state does not require new view controller, so just return.
            return
        }
        
        // Remove existing overlay controller (if any) from game manager listeners
        if let currentListener = overlayViewController as? ExerciseStateChangeObserverViewController {
            currentListener.stopObservingStateChanges()
        }
        
        presentOverlayViewController(controllerToPresent) {
            //Adjust safe area insets on overlay controller to match actual video outpput area.
            if let cameraVC = self.cameraViewController {
                let viewRect = cameraVC.view.frame
                let videoRect = VisionHelper.viewRectForVisionRect(CGRect(x: 0, y: 0, width: 1, height: 1), cameraFeedView: cameraVC.cameraFeedView)
                let insets = controllerToPresent.view.safeAreaInsets
                let additionalInsets = UIEdgeInsets(
                    top: videoRect.minY - viewRect.minY - insets.top,
                    left: videoRect.minX - viewRect.minX - insets.left,
                    bottom: viewRect.maxY - videoRect.maxY - insets.bottom,
                    right: viewRect.maxX - videoRect.maxX - insets.right)
                controllerToPresent.additionalSafeAreaInsets = additionalInsets
            }
            
            // If new overlay controller conforms to GameManagerListener, add it to the listeners.
            if let gameManagerListener = controllerToPresent as? ExerciseStateChangeObserverViewController {
                gameManagerListener.startObservingStateChanges()
            }
            
            // If new overlay controller conforms to CameraViewControllerOutputDelegate
            // set it as a CameraViewController's delegate, so it can process the frames
            // that are coming from the live camera preview or being read from pre-recorded video file.
            if let outputDelegate = controllerToPresent as? CameraViewControllerOutputDelegate {
                self.cameraViewController.outputDelegate = outputDelegate
            }
        }
    }
    
    private func presentOverlayViewController(_ newOverlayViewController: UIViewController?, completion: (() -> Void)?) {
        defer {
            completion?()
        }
        
        guard overlayViewController != newOverlayViewController else {
            return
        }
        
        if let currentOverlay = overlayViewController {
            currentOverlay.willMove(toParent: nil)
            currentOverlay.beginAppearanceTransition(false, animated: true)
            currentOverlay.view.removeFromSuperview()
            currentOverlay.endAppearanceTransition()
            currentOverlay.removeFromParent()
        }
        
        if let newOverlay = newOverlayViewController {
            newOverlay.view.frame = overlayParentView.bounds
            addChild(newOverlay)
            newOverlay.beginAppearanceTransition(true, animated: true)
            overlayParentView.addSubview(newOverlay.view)
            newOverlay.endAppearanceTransition()
            newOverlay.didMove(toParent: self)
        }
        
        overlayViewController = newOverlayViewController
    }
}
