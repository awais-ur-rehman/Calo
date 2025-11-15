//
//  CameraViewModel.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit
import Combine

@MainActor
class CameraViewModel: ObservableObject {
    @Published var predictions: [FoodPrediction] = []
    @Published var selectedPrediction: FoodPrediction?
    @Published var isProcessing = false
    @Published var error: CaloError?
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var capturedImage: UIImage?
    
    let cameraService = CameraService.shared
    private let classifierService = FoodClassifierService.shared
    private let foodDataService = FoodDataService.shared
    private let permissionManager = PermissionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        permissionStatus = permissionManager.checkCameraPermission()
        
        cameraService.$capturedImage
            .receive(on: DispatchQueue.main)
            .assign(to: &$capturedImage)
    }
    
    func requestPermission() async {
        let granted = await permissionManager.requestCameraPermission()
        permissionStatus = permissionManager.checkCameraPermission()
        
        if granted {
            await cameraService.startSession()
        } else {
            error = .cameraPermissionDenied
        }
    }
    
    func startSession() async {
        await cameraService.startSession()
        permissionStatus = permissionManager.checkCameraPermission()
    }
    
    func stopSession() {
        cameraService.stopSession()
    }
    
    func capturePhoto() {
        print("📸 [CameraViewModel] capturePhoto() called")
        predictions = []
        selectedPrediction = nil
        error = nil
        capturedImage = nil
        cameraService.capturePhoto()
        print("📸 [CameraViewModel] capturePhoto() completed")
    }
    
    func processImage(_ image: UIImage) async {
        print("📸 [CameraViewModel] processImage called")
        print("📸 [CameraViewModel] Image size: \(image.size)")
        
        isProcessing = true
        error = nil
        predictions = []
        selectedPrediction = nil
        
        print("📸 [CameraViewModel] State: isProcessing=\(isProcessing), predictions.count=\(predictions.count), error=\(error?.localizedDescription ?? "nil")")
        
        do {
            print("📸 [CameraViewModel] Step 1: Checking model loaded status...")
            if !classifierService.isModelLoaded {
                print("📸 [CameraViewModel] Model not loaded, loading now...")
                await classifierService.loadModel()
            }
            
            print("📸 [CameraViewModel] Step 2: Model loaded = \(classifierService.isModelLoaded)")
            if !classifierService.isModelLoaded {
                throw CaloError.modelLoadingFailed("Failed to load ML model")
            }
            
            print("📸 [CameraViewModel] Step 3: Checking class names...")
            if foodDataService.classNames.isEmpty {
                print("📸 [CameraViewModel] Class names empty, loading data...")
                await foodDataService.loadData()
            }
            
            let classNames = foodDataService.classNames
            print("📸 [CameraViewModel] Step 4: Class names count = \(classNames.count)")
            guard !classNames.isEmpty else {
                throw CaloError.dataServiceUnavailable
            }
            
            print("📸 [CameraViewModel] Step 5: Starting prediction with \(classNames.count) classes...")
            print("📸 [CameraViewModel] First 5 class names: \(Array(classNames.prefix(5)))")
            
            let results = try await classifierService.predict(image: image, classNames: classNames)
            print("📸 [CameraViewModel] Step 6: Got \(results.count) predictions from classifier")
            
            guard !results.isEmpty else {
                print("📸 [CameraViewModel] ERROR: No predictions returned!")
                throw CaloError.predictionFailed("No predictions returned from model")
            }
            
            print("📸 [CameraViewModel] Step 7: Processing \(results.count) predictions...")
            for (index, result) in results.enumerated() {
                print("📸 [CameraViewModel]   Prediction \(index + 1): \(result.className) - \(result.confidencePercentage.rounded(toPlaces: 2))%")
            }
            
            predictions = results
            selectedPrediction = results.first
            
            print("📸 [CameraViewModel] Step 8: Setting predictions array (count=\(predictions.count))")
            print("📸 [CameraViewModel] Step 9: Setting selectedPrediction = \(selectedPrediction?.className ?? "nil")")
            
            if let first = results.first {
                print("🏆 [CameraViewModel] Top prediction: \(first.displayName) (\(first.confidencePercentage.rounded(toPlaces: 1))%)")
                print("🏆 [CameraViewModel] Top prediction className: \(first.className)")
                
                if let nutrition = foodDataService.getNutritionInfo(for: first.className) {
                    let calories = nutrition.calories(for: nutrition.servingSizeG)
                    print("📊 [CameraViewModel] Nutrition found: \(Int(calories)) calories")
                    print("📊 [CameraViewModel] Nutrition details: protein=\(nutrition.proteinG)g, carbs=\(nutrition.carbsG)g, fat=\(nutrition.fatG)g")
                } else {
                    print("⚠️ [CameraViewModel] No nutrition info found for: \(first.className)")
                    print("⚠️ [CameraViewModel] Available keys in database: \(Array(foodDataService.calorieDatabase.keys.prefix(10)))")
                }
            }
            
            print("📸 [CameraViewModel] Step 10: Final state - isProcessing=\(isProcessing), predictions.count=\(predictions.count), selectedPrediction=\(selectedPrediction?.className ?? "nil")")
        } catch let error as CaloError {
            print("❌ [CameraViewModel] CaloError caught: \(error.localizedDescription)")
            self.error = error
        } catch {
            print("❌ [CameraViewModel] Generic error caught: \(error.localizedDescription)")
            self.error = .predictionFailed(error.localizedDescription)
        }
        
        isProcessing = false
        print("📸 [CameraViewModel] Final: isProcessing=\(isProcessing), predictions.count=\(predictions.count), error=\(self.error?.localizedDescription ?? "nil")")
    }
    
    func selectPrediction(_ prediction: FoodPrediction) {
        selectedPrediction = prediction
    }
}

