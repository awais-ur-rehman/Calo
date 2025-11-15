//
//  OnboardingManager.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation

class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

