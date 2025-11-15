//
//  OnboardingButton.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct OnboardingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 60)
                
                arrowIcon
            }
        }
    }
    
    private var arrowIcon: some View {
        Group {
            if let url = Bundle.main.url(forResource: "arrow", withExtension: "svg", subdirectory: nil) ??
                         Bundle.main.url(forResource: "arrow", withExtension: "svg", subdirectory: "Assets/Images") {
                SVGWebView(url: url, maxWidth: 24, maxHeight: 24)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.purple.ignoresSafeArea()
        VStack {
            Spacer()
            OnboardingButton {
                print("Button tapped")
            }
        }
    }
}

