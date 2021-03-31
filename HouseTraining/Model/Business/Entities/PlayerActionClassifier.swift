//
//  PlayerActionClassifier.swift
//  Created by Apple.
//  Source: https://developer.apple.com/videos/play/wwdc2020/10653/
//

import CoreML

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PlayerActionClassifier {
    let model: MLModel
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "HouseTrainingActionClassifier", withExtension:"mlmodelc")!
    }
    
    init(model: MLModel) {
        self.model = model
    }
    
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }
    
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }
    
    @available(macOS 10.16, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Result<PlayerActionClassifier, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }
    
    @available(macOS 10.16, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Result<PlayerActionClassifier, Error>) -> Void) {
        MLModel.__loadContents(of: modelURL, configuration: configuration) { (model, error) in
            if let error = error {
                handler(.failure(error))
            } else if let model = model {
                handler(.success(PlayerActionClassifier(model: model)))
            } else {
                fatalError("SPI failure: -[MLModel loadContentsOfURL:configuration::completionHandler:] vends nil for both model and error.")
            }
        }
    }
    
    func prediction(input: PlayerActionClassifierInput) throws -> PlayerActionClassifierOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }
    
    func prediction(input: PlayerActionClassifierInput, options: MLPredictionOptions) throws -> PlayerActionClassifierOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return PlayerActionClassifierOutput(features: outFeatures)
    }
    
    func prediction(poses: MLMultiArray) throws -> PlayerActionClassifierOutput {
        let input_ = PlayerActionClassifierInput(poses: poses)
        return try self.prediction(input: input_)
    }
    
    func predictions(inputs: [PlayerActionClassifierInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [PlayerActionClassifierOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [PlayerActionClassifierOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  PlayerActionClassifierOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
