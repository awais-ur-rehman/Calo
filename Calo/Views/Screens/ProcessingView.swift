//
//  ProcessingView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct ProcessingView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    
    let capturedImage: UIImage
    let onFoodScanned: (FoodItem) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                    
                    Group {
                        let _ = print("🎨 [ProcessingView] Rendering - isProcessing: \(viewModel.isProcessing), predictions.count: \(viewModel.predictions.count), error: \(viewModel.error?.localizedDescription ?? "nil"), selectedPrediction: \(viewModel.selectedPrediction?.className ?? "nil")")
                        
                        if viewModel.isProcessing {
                            processingSection
                        } else if let error = viewModel.error {
                            errorSection(error)
                        } else if !viewModel.predictions.isEmpty {
                            resultsSection
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                Text("No predictions found")
                                    .font(.headline)
                                Text("Please try again")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button("Retry") {
                                    Task {
                                        await viewModel.processImage(capturedImage)
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Processing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.predictions = []
                        viewModel.selectedPrediction = nil
                        viewModel.error = nil
                        dismiss()
                    }
                }
            }
            .onDisappear {
                viewModel.predictions = []
                viewModel.selectedPrediction = nil
                viewModel.error = nil
            }
            .task {
                print("🎨 [ProcessingView] .task modifier called, starting processImage")
                await viewModel.processImage(capturedImage)
                print("🎨 [ProcessingView] .task modifier completed")
            }
        }
    }
    
    private var processingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .scaleEffect(1.5)
            
            Text("Analyzing food...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var resultsSection: some View {
        VStack(spacing: 20) {
            if let selected = viewModel.selectedPrediction {
                VStack(spacing: 16) {
                    Text(selected.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(selected.confidencePercentage.rounded(toPlaces: 1))% confidence")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let nutrition = FoodDataService.shared.getNutritionInfo(for: selected.className) {
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(Int(nutrition.calories(for: nutrition.servingSizeG)))")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("Calories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(nutrition.proteinG.rounded(toPlaces: 1))g")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Protein")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(nutrition.carbsG.rounded(toPlaces: 1))g")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Carbs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(nutrition.fatG.rounded(toPlaces: 1))g")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Fat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        Text("Nutrition information not available for this food")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            
            if viewModel.predictions.count > 1 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Other Predictions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.predictions) { prediction in
                        if prediction.id != viewModel.selectedPrediction?.id {
                            PredictionRowView(
                                prediction: prediction,
                                isSelected: false,
                                onTap: {
                                    viewModel.selectPrediction(prediction)
                                }
                            )
                        }
                    }
                }
            }
            
            if let selected = viewModel.selectedPrediction {
                Button("Add Food") {
                    handlePredictionSelected(selected)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
    }
    
    private func errorSection(_ error: CaloError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.processImage(capturedImage)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func handlePredictionSelected(_ prediction: FoodPrediction) {
        guard let nutritionInfo = FoodDataService.shared.getNutritionInfo(for: prediction.className) else {
            return
        }
        
        let foodItem = FoodItem(
            name: FoodDataService.shared.getDisplayName(for: prediction.className),
            nutritionInfo: nutritionInfo,
            scannedDate: Date(),
            imageData: capturedImage.jpegData(compressionQuality: 0.8)
        )
        
        onFoodScanned(foodItem)
        dismiss()
    }
}

#Preview {
    ProcessingView(
        viewModel: CameraViewModel(),
        capturedImage: UIImage(systemName: "photo")!,
        onFoodScanned: { _ in }
    )
}

