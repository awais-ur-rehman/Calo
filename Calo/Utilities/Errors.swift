//
//  Errors.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

enum CaloError: LocalizedError {
    case cameraPermissionDenied
    case cameraUnavailable
    case modelLoadingFailed(String)
    case predictionFailed(String)
    case jsonLoadingFailed(String)
    case invalidImage
    case dataServiceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission is required to scan food items. Please enable camera access in Settings."
        case .cameraUnavailable:
            return "Camera is not available on this device."
        case .modelLoadingFailed(let message):
            return "Failed to load ML model: \(message)"
        case .predictionFailed(let message):
            return "Failed to predict food: \(message)"
        case .jsonLoadingFailed(let message):
            return "Failed to load data: \(message)"
        case .invalidImage:
            return "Invalid image provided."
        case .dataServiceUnavailable:
            return "Data service is not available."
        }
    }
}

