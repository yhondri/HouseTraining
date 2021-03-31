//
//  PlayerActionClassifierOutput.swift
//  Created by Apple.
//  Source: https://developer.apple.com/videos/play/wwdc2020/10653/
//

import CoreML

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PlayerActionClassifierOutput : MLFeatureProvider {

    private let provider : MLFeatureProvider

    lazy var labelProbabilities: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "labelProbabilities")!.dictionaryValue as! [String : Double]
    }()
    
    lazy var label: String = {
        [unowned self] in return self.provider.featureValue(for: "label")!.stringValue
    }()

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    var actionProbability: Double {
        labelProbabilities[label] ?? 0.0
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(labelProbabilities: [String : Double], label: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["labelProbabilities" : MLFeatureValue(dictionary: labelProbabilities as [AnyHashable : NSNumber]), "label" : MLFeatureValue(string: label)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}

