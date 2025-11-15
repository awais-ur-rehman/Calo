//
//  Constants.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

enum Constants {
    enum ML {
        static let modelName = "mobilenetv2_food101-v1.2"
        static let inputImageSize = 224
        static let topPredictionsCount = 5
    }
    
    enum Data {
        static let classNamesFile = "class_names"
        static let calorieDatabaseFile = "calorie_database"
    }
    
    enum Camera {
        static let cameraUsageDescription = "We need camera access to scan and identify food items for calorie tracking."
    }
}

