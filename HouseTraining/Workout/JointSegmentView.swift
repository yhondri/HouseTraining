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
        jointSegmentLayer.strokeColor = #colorLiteral(red: 0.6078431373, green: 0.9882352941, blue: 0, alpha: 1).cgColor
        layer.addSublayer(jointSegmentLayer)
        let jointColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        jointLayer.strokeColor = jointColor
        jointLayer.fillColor = jointColor
        layer.addSublayer(jointLayer)
    }

    private func updatePathLayer() {
        let scaleToBounds = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
        jointPath.removeAllPoints()
        jointSegmentPath.removeAllPoints()
        
        var rightShoulderPoint: CGPoint = .zero
        var leftShoulderPoint: CGPoint = .zero

        // Add all joints and segments
        for index in 0 ..< jointsOfInterest.count {
            if let nextJoint = joints[jointsOfInterest[index]] {
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
                    
                    if jointsOfInterest[index] == .rightShoulder {
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
        }
        
        jointSegmentPath.move(to: leftShoulderPoint)
        jointSegmentPath.addLine(to: rightShoulderPoint)
        
        jointLayer.path = jointPath.cgPath
        jointSegmentLayer.path = jointSegmentPath.cgPath
    }
}

extension UIBezierPath {
    func rotateAroundCenter(angle: CGFloat) {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        self.apply(transform)
    }
}
