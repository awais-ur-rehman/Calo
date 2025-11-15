//
//  JSONLoader.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

class JSONLoader {
    static let shared = JSONLoader()
    
    private init() {}
    
    func loadJSON<T: Decodable>(from fileName: String, as type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw CaloError.jsonLoadingFailed("File \(fileName).json not found in bundle")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CaloError.jsonLoadingFailed("Failed to decode \(fileName).json: \(error.localizedDescription)")
        }
    }
    
    func loadClassNames() throws -> [String] {
        try loadJSON(from: Constants.Data.classNamesFile, as: [String].self)
    }
    
    func loadCalorieDatabase() throws -> [String: NutritionInfo] {
        try loadJSON(from: Constants.Data.calorieDatabaseFile, as: [String: NutritionInfo].self)
    }
}

