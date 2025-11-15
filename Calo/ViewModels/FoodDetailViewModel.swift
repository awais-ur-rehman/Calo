//
//  FoodDetailViewModel.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation
import SwiftUI

@MainActor
class FoodDetailViewModel: ObservableObject {
    @Published var servingSize: Double = 100.0
    
    let foodItem: FoodItem
    
    init(foodItem: FoodItem) {
        self.foodItem = foodItem
        self.servingSize = foodItem.nutritionInfo.servingSizeG
    }
    
    var calories: Double {
        foodItem.nutritionInfo.calories(for: servingSize).rounded(toPlaces: 1)
    }
    
    var protein: Double {
        foodItem.nutritionInfo.protein(for: servingSize).rounded(toPlaces: 1)
    }
    
    var carbs: Double {
        foodItem.nutritionInfo.carbs(for: servingSize).rounded(toPlaces: 1)
    }
    
    var fat: Double {
        foodItem.nutritionInfo.fat(for: servingSize).rounded(toPlaces: 1)
    }
}

