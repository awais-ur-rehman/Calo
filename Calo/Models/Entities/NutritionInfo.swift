//
//  NutritionInfo.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

struct NutritionInfo: Codable {
    let caloriesPer100g: Double
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let servingSizeG: Double
    
    enum CodingKeys: String, CodingKey {
        case caloriesPer100g = "calories_per_100g"
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case servingSizeG = "serving_size_g"
    }
    
    func calories(for servingSize: Double) -> Double {
        (caloriesPer100g / 100.0) * servingSize
    }
    
    func protein(for servingSize: Double) -> Double {
        (proteinG / 100.0) * servingSize
    }
    
    func carbs(for servingSize: Double) -> Double {
        (carbsG / 100.0) * servingSize
    }
    
    func fat(for servingSize: Double) -> Double {
        (fatG / 100.0) * servingSize
    }
}

