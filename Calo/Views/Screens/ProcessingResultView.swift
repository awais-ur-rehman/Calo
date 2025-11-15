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
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
    }
    
    private var skeletonLoadingSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Analyzing food...")
                    .font(.spaceGrotesk(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
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
            .padding()
        }
    }
    
    private var resultsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let selected = viewModel.selectedPrediction {
                    foodNameSection(selected)
                    
                    if let nutrition = FoodDataService.shared.getNutritionInfo(for: selected.className) {
                        nutritionGrid(nutrition: nutrition)
                    } else {
                        Text("Nutrition information not available for this food")
                            .font(.spaceGrotesk(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                actionButtonsSection
            }
            .padding()
        }
    }
    
    private func foodNameSection(_ prediction: FoodPrediction) -> some View {
        Text(prediction.displayName)
            .font(.spaceGrotesk(size: 24, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
    
    private func nutritionGrid(nutrition: NutritionInfo) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                nutritionBox(
                    title: "Calories",
                    value: "\(Int(nutrition.calories(for: nutrition.servingSizeG)))kcal",
                    color: "DDC0FF"
                )
                
                nutritionBox(
                    title: "Protein",
                    value: "\(nutrition.protein(for: nutrition.servingSizeG).rounded(toPlaces: 1))g",
                    color: "45C588"
                )
            }
            
            HStack(spacing: 12) {
                nutritionBox(
                    title: "Carbs",
                    value: "\(nutrition.carbs(for: nutrition.servingSizeG).rounded(toPlaces: 1))g",
                    color: "F5F378"
                )
                
                nutritionBox(
                    title: "Fat",
                    value: "\(nutrition.fat(for: nutrition.servingSizeG).rounded(toPlaces: 1))g",
                    color: "FF6F43"
                )
            }
        }
    }
    
    private func nutritionBox(title: String, value: String, color: String) -> some View {
        ZStack(alignment: .topLeading) {
            Color(hex: color)
                .frame(height: 120)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.spaceGrotesk(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.top, 12)
                    .padding(.leading, 12)
                
                Spacer()
                
                if title == "Calories" {
                    Text(value)
                        .font(.spaceGrotesk(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.leading, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(value)
                        .font(.spaceGrotesk(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
                        .font(.spaceGrotesk(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "45C588"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var emptyStateSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("No predictions found")
                    .font(.spaceGrotesk(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Please try again")
                    .font(.spaceGrotesk(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                
                Button("Retry") {
                    Task {
                        await viewModel.processImage(capturedImage)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            .padding()
        }
    }
    
    private func errorSection(_ error: CaloError) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Error")
                    .font(.spaceGrotesk(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(error.localizedDescription)
                    .font(.spaceGrotesk(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Button("Try Again") {
                    Task {
                        await viewModel.processImage(capturedImage)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            .padding()
        }
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
            .fill(Color.white.opacity(0.1))
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
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

