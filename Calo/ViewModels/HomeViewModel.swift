//
//  HomeViewModel.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var error: CaloError?
    
    private let foodDataService = FoodDataService.shared
    
    init() {
        loadMockData()
    }
    
    func addFoodItem(_ item: FoodItem) {
        foodItems.insert(item, at: 0)
    }
    
    func deleteFoodItem(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }
    
    private func loadMockData() {
        guard let nutritionInfo = foodDataService.getNutritionInfo(for: "apple_pie") else {
            return
        }
        
        let mockItem = FoodItem(
            name: foodDataService.getDisplayName(for: "apple_pie"),
            nutritionInfo: nutritionInfo,
            scannedDate: Date()
        )
        foodItems = [mockItem]
    }
}

