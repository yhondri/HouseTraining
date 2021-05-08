import UIKit
import Vision

class JointSegmentView: UIView, AnimatedTransitioning {
    var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:] {
        didSet {
            updatePathLayer()
        }
    }

    private let jointRadius: CGFloat = 3.0
    private let jointLayer = CAShapeLayer()
    private var jointPath = UIBezierPath()

    private let jointSegmentWidth: CGFloat = 2.0
    private let jointSegmentLayer = CAShapeLayer()
    private var jointSegmentPath = UIBezierPath()
        
    let jointsOfInterest: [VNHumanBodyPoseObservation.JointName] = [.rightWrist,
                                                                    .rightElbow,
                                                                    .rightShoulder,
                                                                    .rightHip,
                                                                    .rightKnee,
                                                                    .rightAnkle,
                                                                    .leftWrist,
                                                                    .leftElbow,
                                                                    .leftShoulder,
                                                                    .leftHip,
                                                                    .leftKnee,
                                                                    .leftAnkle]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    func resetView() {
        jointLayer.path = nil
        jointSegmentLayer.path = nil
    }

    private func setupLayer() {
        jointSegmentLayer.lineCap = .round
        jointSegmentLayer.lineWidth = jointSegmentWidth
        jointSegmentLayer.fillColor = UIColor.clear.cgColor
        jointSegmentLayer.strokeColor = UIColor.charBarTopColor?.cgColor
        layer.addSublayer(jointSegmentLayer)
        let jointColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        jointLayer.strokeColor = jointColor
        jointLayer.fillColor = jointColor
        layer.addSublayer(jointLayer)
    }
    
    private var pixelateFace: UIVisualEffectView?
    
    func setupBlurFace(faceObservation: VNFaceObservation) {
        if let pixelateFace = pixelateFace {
            pixelateFace.removeFromSuperview()
        }
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.frame.height)
        let translate = CGAffineTransform.identity.scaledBy(x: self.frame.width, y: self.frame.height)
        
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = faceObservation.boundingBox.applying(translate).applying(transform)
        
        let blurEffect = UIBlurEffect(style: .light)
        pixelateFace = UIVisualEffectView(effect: blurEffect)
        pixelateFace?.frame = facebounds
        
//        faceMask = UIView(frame: facebounds)
//        pixelateFace?.backgroundColor = .red
        addSubview(pixelateFace!)
    }

    private func updatePathLayer() {
        let scaleToBounds = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
        jointPath.removeAllPoints()
        jointSegmentPath.removeAllPoints()
        
        var rightShoulderPoint: CGPoint = .zero
        var leftShoulderPoint: CGPoint = .zero

        var index = 0
        
        // Add all joints and segments
        for jointOfInterest in jointsOfInterest {
            if let nextJoint = joints[jointOfInterest] {
                let nextJointScaled = nextJoint
                    .applying(CGAffineTransform.verticalFlip)
                    .applying(scaleToBounds)
                let nextJointPath = UIBezierPath(arcCenter: nextJointScaled,
                                                 radius: jointRadius,
                                                 startAngle: CGFloat(0),
                                                 endAngle: CGFloat.pi * 2,
                                                 clockwise: true)
                jointPath.append(nextJointPath)
                
                if index <= 5 {
                    if jointSegmentPath.isEmpty {
                        jointSegmentPath.move(to: nextJointScaled)
                    } else {
                        jointSegmentPath.addLine(to: nextJointScaled)
                    }
                    
                    if jointOfInterest == .rightShoulder {
                        rightShoulderPoint = nextJointScaled
                    }
                } else {
                    if index == 6 {
                        jointSegmentPath.move(to: nextJointScaled)
                    } else {
                        jointSegmentPath.addLine(to: nextJointScaled)
                    }
                    
                    if jointsOfInterest[index] == .leftShoulder {
                        leftShoulderPoint = nextJointScaled
                    }
                }
            }
            
            index += 1
        }
        
        jointSegmentPath.move(to: leftShoulderPoint)
        jointSegmentPath.addLine(to: rightShoulderPoint)
        
        jointLayer.path = jointPath.cgPath
        jointSegmentLayer.path = jointSegmentPath.cgPath
    }
}
