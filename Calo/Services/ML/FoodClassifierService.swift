//
//  FoodClassifierService.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation
import CoreML
import UIKit

@MainActor
class FoodClassifierService: ObservableObject {
    static let shared = FoodClassifierService()
    
    @Published private(set) var isModelLoaded = false
    @Published private(set) var isPredicting = false
    @Published private(set) var error: CaloError?
    
    private var model: MLModel?
    private let imagePreprocessor = ImagePreprocessor.shared
    
    private init() {}
    
    func loadModel() async {
        guard !isModelLoaded else { return }
        
        do {
            let bundle = Bundle.main
            var modelURL: URL?
            
            // Try different possible locations/extensions
            // 1. Try .mlpackage (original format)
            if let url = bundle.url(forResource: Constants.ML.modelName, withExtension: "mlpackage") {
                modelURL = url
                print("✅ Found model as .mlpackage at: \(url.path)")
            }
            // 2. Try .mlmodelc (compiled format that Xcode creates)
            else if let url = bundle.url(forResource: Constants.ML.modelName, withExtension: "mlmodelc") {
                modelURL = url
                print("✅ Found model as .mlmodelc at: \(url.path)")
            }
            // 3. Try without extension (CoreML can find it by name)
            else if let url = bundle.url(forResource: Constants.ML.modelName, withExtension: nil) {
                modelURL = url
                print("✅ Found model without extension at: \(url.path)")
            }
            // 4. Try searching in bundle resources
            else {
                let fileManager = FileManager.default
                if let resourcePath = bundle.resourcePath {
                    let possiblePaths = [
                        "\(resourcePath)/\(Constants.ML.modelName).mlpackage",
                        "\(resourcePath)/\(Constants.ML.modelName).mlmodelc",
                        "\(resourcePath)/\(Constants.ML.modelName)"
                    ]
                    
                    for path in possiblePaths {
                        if fileManager.fileExists(atPath: path) {
                            modelURL = URL(fileURLWithPath: path)
                            print("✅ Found model at: \(path)")
                            break
                        }
                    }
                }
            }
            
            guard let finalModelURL = modelURL else {
                // Debug: List all files in bundle
                if let resourcePath = bundle.resourcePath {
                    let fileManager = FileManager.default
                    if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                        print("📦 Bundle contents: \(contents.joined(separator: ", "))")
                    }
                }
                let errorMsg = "Model file '\(Constants.ML.modelName)' not found in bundle (tried .mlpackage, .mlmodelc, and without extension)."
                print("❌ \(errorMsg)")
                throw CaloError.modelLoadingFailed(errorMsg)
            }
            
            print("✅ Loading model from: \(finalModelURL.path)")
            let config = MLModelConfiguration()
            config.computeUnits = .all
            model = try MLModel(contentsOf: finalModelURL, configuration: config)
            isModelLoaded = true
            print("✅ Model loaded successfully")
        } catch {
            let errorMsg = error.localizedDescription
            print("❌ Model loading failed: \(errorMsg)")
            self.error = .modelLoadingFailed(errorMsg)
            isModelLoaded = false
        }
    }
    
    func predict(image: UIImage, classNames: [String]) async throws -> [FoodPrediction] {
        print("🤖 [FoodClassifierService] predict called")
        print("🤖 [FoodClassifierService] Image size: \(image.size)")
        print("🤖 [FoodClassifierService] Class names count: \(classNames.count)")
        
        guard isModelLoaded, let model = model else {
            print("❌ [FoodClassifierService] Model not loaded!")
            throw CaloError.modelLoadingFailed("Model not loaded")
        }
        
        guard classNames.count > 0 else {
            print("❌ [FoodClassifierService] No class names provided!")
            throw CaloError.predictionFailed("Class names not available")
        }
        
        isPredicting = true
        defer { 
            isPredicting = false
            print("🤖 [FoodClassifierService] isPredicting set to false")
        }
        
        return try await Task.detached {
            print("🤖 [FoodClassifierService] Task.detached started")
            
            print("🤖 [FoodClassifierService] Step 1: Preprocessing image...")
            let pixelBuffer = try self.imagePreprocessor.preprocessImage(image)
            print("🤖 [FoodClassifierService] Image preprocessed, pixelBuffer size: \(CVPixelBufferGetWidth(pixelBuffer))x\(CVPixelBufferGetHeight(pixelBuffer))")
            
            print("🤖 [FoodClassifierService] Step 2: Creating MLFeatureValue...")
            let input = try MLFeatureValue(pixelBuffer: pixelBuffer)
            
            // Try different input key names that models might use
            let possibleInputKeys = ["input_1", "image", "input", "image_input"]
            var inputProvider: MLFeatureProvider?
            var usedKey: String?
            
            for key in possibleInputKeys {
                do {
                    inputProvider = try MLDictionaryFeatureProvider(dictionary: [key: input])
                    usedKey = key
                    print("🤖 [FoodClassifierService] Input provider created with key: '\(key)'")
                    break
                } catch {
                    print("🤖 [FoodClassifierService] Failed with key '\(key)': \(error.localizedDescription)")
                }
            }
            
            guard let provider = inputProvider, let key = usedKey else {
                print("❌ [FoodClassifierService] Failed to create input provider with any key")
                throw CaloError.predictionFailed("Failed to create model input")
            }
            
            print("🤖 [FoodClassifierService] Using input key: '\(key)'")
            
            print("🤖 [FoodClassifierService] Step 3: Running model prediction...")
            let prediction = try model.prediction(from: provider)
            print("🤖 [FoodClassifierService] Prediction received")
            print("🤖 [FoodClassifierService] Prediction feature names: \(prediction.featureNames)")
            
            var logits: MLMultiArray?
            
            print("🤖 [FoodClassifierService] Step 4: Looking for output key...")
            // Try common output keys, including var_852 which this model uses
            let possibleOutputKeys = ["var_852", "classLabelProbs", "probabilities", "output", "prediction"]
            for key in possibleOutputKeys {
                if let output = prediction.featureValue(for: key)?.multiArrayValue {
                    logits = output
                    print("🤖 [FoodClassifierService] Found output key: '\(key)'")
                    print("🤖 [FoodClassifierService] Output array count: \(output.count)")
                    print("🤖 [FoodClassifierService] Output shape: \(output.shape)")
                    break
                } else {
                    print("🤖 [FoodClassifierService] Key '\(key)' not found or not multiArray")
                }
            }
            
            guard let rawOutput = logits else {
                let availableKeys = prediction.featureNames.joined(separator: ", ")
                print("❌ [FoodClassifierService] No valid output found! Available keys: \(availableKeys)")
                throw CaloError.predictionFailed("Invalid model output. Available keys: \(availableKeys)")
            }
            
            print("🤖 [FoodClassifierService] Step 5: Converting logits to probabilities...")
            
            // Extract logits and convert to probabilities using softmax
            var logitsArray: [Double] = []
            for i in 0..<rawOutput.count {
                logitsArray.append(Double(truncating: rawOutput[i]))
            }
            
            // Apply softmax: exp(x_i) / sum(exp(x_j))
            let maxLogit = logitsArray.max() ?? 0.0
            let expLogits = logitsArray.map { exp($0 - maxLogit) } // Subtract max for numerical stability
            let sumExp = expLogits.reduce(0, +)
            let probabilities = expLogits.map { $0 / sumExp }
            
            print("🤖 [FoodClassifierService] Step 6: Processing \(probabilities.count) probabilities...")
            var predictions: [(className: String, confidence: Double)] = []
            
            for i in 0..<min(probabilities.count, classNames.count) {
                let confidence = probabilities[i]
                let className = classNames[i]
                predictions.append((className: className, confidence: confidence))
                
                if i < 5 {
                    print("🤖 [FoodClassifierService]   [\(i)] \(className): \(confidence)")
                }
            }
            
            print("🤖 [FoodClassifierService] Step 6: Sorting predictions...")
            let sorted = predictions.sorted { $0.confidence > $1.confidence }
            print("🤖 [FoodClassifierService] Top 5 confidences: \(sorted.prefix(5).map { "\($0.className): \($0.confidence)" })")
            
            let topPredictions = sorted
                .prefix(Constants.ML.topPredictionsCount)
                .map { FoodPrediction(className: $0.className, confidence: $0.confidence) }
            
            print("🤖 [FoodClassifierService] Step 7: Returning \(topPredictions.count) predictions")
            for (index, pred) in topPredictions.enumerated() {
                print("🤖 [FoodClassifierService]   [\(index)] \(pred.className) - \(pred.confidencePercentage.rounded(toPlaces: 2))%")
            }
            
            return Array(topPredictions)
        }.value
    }
}

