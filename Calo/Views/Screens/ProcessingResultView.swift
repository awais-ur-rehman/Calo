//
//  ProcessingResultView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct ProcessingResultView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    
    let capturedImage: UIImage
    let onFoodScanned: (FoodItem) -> Void
    let onRetake: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                imageSection
                
                if viewModel.isProcessing {
                    skeletonLoadingSection
                } else if let error = viewModel.error {
                    errorSection(error)
                } else if !viewModel.predictions.isEmpty {
                    resultsSection
                } else {
                    emptyStateSection
                }
            }
            .padding()
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.processImage(capturedImage)
        }
        .onDisappear {
            if viewModel.isProcessing {
                viewModel.predictions = []
                viewModel.selectedPrediction = nil
                viewModel.error = nil
            }
        }
    }
    
    private var imageSection: some View {
        Image(uiImage: capturedImage)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .cornerRadius(12)
    }
    
    private var skeletonLoadingSection: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .scaleEffect(1.5)
            
            Text("Analyzing food...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                SkeletonView()
                    .frame(height: 60)
                    .cornerRadius(8)
                
                SkeletonView()
                    .frame(height: 120)
                    .cornerRadius(8)
                
                SkeletonView()
                    .frame(height: 80)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var resultsSection: some View {
        VStack(spacing: 24) {
            if let selected = viewModel.selectedPrediction {
                VStack(spacing: 16) {
                    Text(selected.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(selected.confidencePercentage.rounded(toPlaces: 1))% confidence")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let nutrition = FoodDataService.shared.getNutritionInfo(for: selected.className) {
                        nutritionInfoView(nutrition: nutrition)
                    } else {
                        Text("Nutrition information not available for this food")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            
            if viewModel.predictions.count > 1 {
                otherPredictionsSection
            }
            
            actionButtonsSection
        }
    }
    
    private func nutritionInfoView(nutrition: NutritionInfo) -> some View {
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
    }
    
    private var otherPredictionsSection: some View {
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
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if let selected = viewModel.selectedPrediction {
                Button {
                    handleAddFood(selected)
                } label: {
                    Text("Add Food")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyStateSection: some View {
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
    
    private func handleAddFood(_ prediction: FoodPrediction) {
        guard let nutritionInfo = FoodDataService.shared.getNutritionInfo(for: prediction.className) else {
            return
        }
        
        let foodItem = FoodItem(
            name: FoodDataService.shared.getDisplayName(for: prediction.className),
            nutritionInfo: nutritionInfo,
            scannedDate: Date(),
            imageData: capturedImage.jpegData(compressionQuality: 0.8)
        )
        
        viewModel.predictions = []
        viewModel.selectedPrediction = nil
        viewModel.capturedImage = nil
        onFoodScanned(foodItem)
        
        Task { @MainActor in
            dismiss()
            try? await Task.sleep(nanoseconds: 150_000_000)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                findNavigationController(from: rootViewController)?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func findNavigationController(from viewController: UIViewController) -> UINavigationController? {
        if let navController = viewController as? UINavigationController {
            return navController
        }
        
        for child in viewController.children {
            if let navController = findNavigationController(from: child) {
                return navController
            }
        }
        
        if let presented = viewController.presentedViewController {
            return findNavigationController(from: presented)
        }
        
        return nil
    }
    
    private func handleRetake() {
        viewModel.predictions = []
        viewModel.selectedPrediction = nil
        viewModel.error = nil
        viewModel.capturedImage = nil
        onRetake()
        dismiss()
    }
}

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray5),
                                Color(.systemGray4),
                                Color(.systemGray5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    NavigationView {
        ProcessingResultView(
            viewModel: CameraViewModel(),
            capturedImage: UIImage(systemName: "photo")!,
            onFoodScanned: { _ in },
            onRetake: {}
        )
    }
}

