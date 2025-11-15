//
//  FoodDataService.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

@MainActor
class FoodDataService: ObservableObject {
    static let shared = FoodDataService()
    
    @Published private(set) var classNames: [String] = []
    @Published private(set) var calorieDatabase: [String: NutritionInfo] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var error: CaloError?
    
    private let jsonLoader = JSONLoader.shared
    
    private init() {}
    
    func loadData() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            async let names = jsonLoader.loadClassNames()
            async let database = jsonLoader.loadCalorieDatabase()
            
            classNames = try await names
            calorieDatabase = try await database
            
            print("✅ Loaded \(classNames.count) class names")
            print("✅ Loaded \(calorieDatabase.count) food items in calorie database")
        } catch let error as CaloError {
            print("❌ Data loading error: \(error.localizedDescription ?? "Unknown")")
            self.error = error
        } catch {
            print("❌ Data loading error: \(error.localizedDescription)")
            self.error = .jsonLoadingFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func getNutritionInfo(for className: String) -> NutritionInfo? {
        calorieDatabase[className]
    }
    
    func getDisplayName(for className: String) -> String {
        className.formattedFoodName()
    }
}

