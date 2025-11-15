//
//  FoodCardView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct FoodCardView: View {
    let foodItem: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(foodItem.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Label("\(Int(foodItem.nutritionInfo.calories(for: foodItem.nutritionInfo.servingSizeG)))", systemImage: "flame.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(foodItem.scannedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    FoodCardView(foodItem: FoodItem(
        name: "Apple Pie",
        nutritionInfo: NutritionInfo(
            caloriesPer100g: 237,
            proteinG: 2,
            carbsG: 34,
            fatG: 11,
            servingSizeG: 125
        )
    ))
    .padding()
}

