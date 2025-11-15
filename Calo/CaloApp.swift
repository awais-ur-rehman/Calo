//
//  CaloApp.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

@main
struct CaloApp: App {
    @StateObject private var foodDataService = FoodDataService.shared
    @StateObject private var classifierService = FoodClassifierService.shared
    @State private var showSplash = true
    
    init() {
        Task {
            await FoodDataService.shared.loadData()
            await FoodClassifierService.shared.loadModel()
        }
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                HomeView()
            }
        }
    }
}
