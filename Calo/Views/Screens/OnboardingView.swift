//
//  OnboardingView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let screens: [OnboardingScreenData] = [
        OnboardingScreenData(
            backgroundColor: "DDC0FF",
            svgFileName: "good",
            title: "Your Smart Nutrition Companion",
            description: "Track your meals, monitor nutrients, and reach your health goals with AI-powered support."
        ),
        OnboardingScreenData(
            backgroundColor: "45C588",
            svgFileName: "groovy",
            title: "Track Everything That Matters",
            description: "Log calories, macros, water, and activity — all in one place."
        ),
        OnboardingScreenData(
            backgroundColor: "FF6F43",
            svgFileName: "lemon",
            title: "Your Health Journey Starts Here",
            description: "We help you choose healthier foods and enjoy tasty, nutritious meals for your well-being.",
            buttonText: "Get Started"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<screens.count, id: \.self) { index in
                OnboardingScreen(
                    backgroundColor: screens[index].backgroundColor,
                    svgFileName: screens[index].svgFileName,
                    title: screens[index].title,
                    description: screens[index].description,
                    buttonText: screens[index].buttonText,
                    onNext: {
                        if index < screens.count - 1 {
                            withAnimation {
                                currentPage = index + 1
                            }
                        } else {
                            onComplete()
                        }
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
    }
}

struct OnboardingScreenData {
    let backgroundColor: String
    let svgFileName: String
    let title: String
    let description: String
    let buttonText: String
    
    init(
        backgroundColor: String,
        svgFileName: String,
        title: String,
        description: String,
        buttonText: String = "Next"
    ) {
        self.backgroundColor = backgroundColor
        self.svgFileName = svgFileName
        self.title = title
        self.description = description
        self.buttonText = buttonText
    }
}

#Preview {
    OnboardingView(onComplete: {})
}

