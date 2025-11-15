//
//  OnboardingScreen.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct OnboardingScreen: View {
    let backgroundColor: String
    let svgFileName: String
    let title: String
    let description: String
    let onNext: () -> Void
    
    init(
        backgroundColor: String,
        svgFileName: String,
        title: String,
        description: String,
        onNext: @escaping () -> Void
    ) {
        self.backgroundColor = backgroundColor
        self.svgFileName = svgFileName
        self.title = title
        self.description = description
        self.onNext = onNext
    }
    
    var body: some View {
        ZStack {
            Color(hex: backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)
                
                illustrationView
                    .frame(height: 350)
                
                Spacer()
                
                textContent
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                
                buttonView
            }
        }
    }
    
    private var illustrationView: some View {
        Group {
            if let url = Bundle.main.url(forResource: svgFileName, withExtension: "svg", subdirectory: nil) ??
                         Bundle.main.url(forResource: svgFileName, withExtension: "svg", subdirectory: "Assets/Images") {
                SVGWebView(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 350)
                    .onAppear {
                        print("⚠️ [OnboardingScreen] SVG file not found: \(svgFileName).svg")
                    }
            }
        }
    }
    
    private var textContent: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.spaceGrotesk(size: 26, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(description)
                .font(.spaceGrotesk(size: 16, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var buttonView: some View {
        OnboardingButton(action: onNext)
            .padding(.bottom, 40)
    }
}

#Preview {
    OnboardingScreen(
        backgroundColor: "DDC0FF",
        svgFileName: "good",
        title: "Your Smart Nutrition Companion",
        description: "Track your meals, monitor nutrients, and reach your health goals with AI-powered support.",
        onNext: {}
    )
}

