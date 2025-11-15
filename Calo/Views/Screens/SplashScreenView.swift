//
//  SplashScreenView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(hex: "171517")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Calo")
                        .font(.spaceGrotesk(size: 64, weight: .bold))
                        .foregroundColor(.white)
                    
                    taglineView
                }
                
                Spacer()
                
                splashIconsView
            }
        }
    }
    
    private var taglineView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("Eating")
                    .font(.spaceGrotesk(size: 24, weight: .regular))
                    .foregroundColor(.white)
                
                Text("Healthy")
                    .font(.spaceGrotesk(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "45C588"))
                    .cornerRadius(20)
            }
            
            Text("made easy!")
                .font(.spaceGrotesk(size: 24, weight: .regular))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var splashIconsView: some View {
        Group {
            if let image = UIImage(named: "splashscreen") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 420, maxHeight: 336)
            } else if let url = Bundle.main.url(forResource: "splashscreen", withExtension: "svg", subdirectory: nil) ??
                         Bundle.main.url(forResource: "splashscreen", withExtension: "svg", subdirectory: "Assets/Images") {
                SVGWebView(url: url, maxWidth: 420, maxHeight: 336)
                    .frame(maxWidth: 420, maxHeight: 336)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 336)
                    .onAppear {
                        print("⚠️ [SplashScreen] SVG file not found. Make sure splashscreen.svg is added to the target in Build Phases.")
                    }
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}


#Preview {
    SplashScreenView()
}

