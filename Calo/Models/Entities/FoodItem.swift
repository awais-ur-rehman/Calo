//
//  FoodItem.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let nutritionInfo: NutritionInfo
    let scannedDate: Date
    let imageData: Data?
    
    init(id: UUID = UUID(), name: String, nutritionInfo: NutritionInfo, scannedDate: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.nutritionInfo = nutritionInfo
        self.scannedDate = scannedDate
        self.imageData = imageData
    }
}

