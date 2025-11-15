//
//  PredictionResultView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct PredictionResultView: View {
    let predictions: [FoodPrediction]
    let onSelect: (FoodPrediction) -> Void
    let selectedPrediction: FoodPrediction?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Predictions")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(predictions) { prediction in
                    PredictionRowView(
                        prediction: prediction,
                        isSelected: selectedPrediction?.id == prediction.id,
                        onTap: { onSelect(prediction) }
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
}

struct PredictionRowView: View {
    let prediction: FoodPrediction
    let isSelected: Bool
    let onTap: () -> Void
    
    private var nutritionInfo: NutritionInfo? {
        FoodDataService.shared.getNutritionInfo(for: prediction.className)
    }
    
    private var caloriesText: String {
        if let nutrition = nutritionInfo {
            let calories = nutrition.calories(for: nutrition.servingSizeG)
            return "\(Int(calories)) cal"
        }
        return "N/A"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prediction.displayName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Text("\(prediction.confidencePercentage.rounded(toPlaces: 1))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if nutritionInfo != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                Text(caloriesText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(isSelected ? Color.black.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#Preview {
    PredictionResultView(
        predictions: [
            FoodPrediction(className: "apple_pie", confidence: 0.85),
            FoodPrediction(className: "chocolate_cake", confidence: 0.12),
            FoodPrediction(className: "cheesecake", confidence: 0.03)
        ],
        onSelect: { _ in },
        selectedPrediction: FoodPrediction(className: "apple_pie", confidence: 0.85)
    )
}

