//
//  PlayerActionClassifierInput.swift
//  HouseTraining
//  Created by Apple.
//  Source: https://developer.apple.com/videos/play/wwdc2020/10653/
//

import CoreML

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PlayerActionClassifierInput : MLFeatureProvider {
    var poses: MLMultiArray

    var featureNames: Set<String> {
        get {
            return ["poses"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "poses") {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }
    
    init(poses: MLMultiArray) {
        self.poses = poses
    }
}
