//
//  FoodPrediction.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

struct FoodPrediction: Identifiable, Equatable {
    let id: UUID
    let className: String
    let confidence: Double
    
    init(id: UUID = UUID(), className: String, confidence: Double) {
        self.id = id
        self.className = className
        self.confidence = confidence
    }
    
    var displayName: String {
        className.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var confidencePercentage: Double {
        confidence * 100
    }
}

