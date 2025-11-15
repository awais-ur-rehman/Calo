//
//  FoodDetailView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct FoodDetailView: View {
    @StateObject private var viewModel: FoodDetailViewModel
    
    init(foodItem: FoodItem) {
        _viewModel = StateObject(wrappedValue: FoodDetailViewModel(foodItem: foodItem))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let imageData = viewModel.foodItem.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.foodItem.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Scanned on \(viewModel.foodItem.scannedDate, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                servingSizeSection
                
                nutritionSection
            }
            .padding()
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var servingSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Serving Size")
                .font(.headline)
            
            HStack {
                Slider(
                    value: Binding(
                        get: { viewModel.servingSize },
                        set: { viewModel.servingSize = $0 }
                    ),
                    in: 10...500,
                    step: 10
                )
                
                Text("\(Int(viewModel.servingSize))g")
                    .font(.body)
                    .frame(width: 60)
            }
        }
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                NutritionRowView(
                    label: "Calories",
                    value: "\(Int(viewModel.calories))",
                    icon: "flame.fill",
                    color: .orange
                )
                
                NutritionRowView(
                    label: "Protein",
                    value: "\(viewModel.protein)g",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                NutritionRowView(
                    label: "Carbs",
                    value: "\(viewModel.carbs)g",
                    icon: "leaf.fill",
                    color: .green
                )
                
                NutritionRowView(
                    label: "Fat",
                    value: "\(viewModel.fat)g",
                    icon: "drop.fill",
                    color: .purple
                )
            }
        }
    }
}

struct NutritionRowView: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        FoodDetailView(foodItem: FoodItem(
            name: "Apple Pie",
            nutritionInfo: NutritionInfo(
                caloriesPer100g: 237,
                proteinG: 2,
                carbsG: 34,
                fatG: 11,
                servingSizeG: 125
            )
        ))
    }
}

