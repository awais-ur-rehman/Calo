//
//  OnboardingButton.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct OnboardingButton: View {
    let action: () -> Void
    let text: String
    
    init(text: String = "Next", action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                whiteTeardropShape
                blackCircularButton
            }
        }
    }
    
    private var whiteTeardropShape: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let radius: CGFloat = 25
                let pointWidth: CGFloat = 20
                let pointHeight: CGFloat = 15
                
                let topLeft = CGPoint(x: radius, y: 0)
                let topRight = CGPoint(x: width - radius, y: 0)
                let bottomLeft = CGPoint(x: width / 2 - pointWidth / 2, y: height - pointHeight)
                let bottomRight = CGPoint(x: width / 2 + pointWidth / 2, y: height - pointHeight)
                let bottomPoint = CGPoint(x: width / 2, y: height)
                
                path.move(to: topLeft)
                path.addLine(to: CGPoint(x: 0, y: radius))
                path.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: 0))
                path.addLine(to: topRight)
                path.addQuadCurve(to: CGPoint(x: width, y: radius), control: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height - pointHeight - radius))
                path.addQuadCurve(to: CGPoint(x: width - radius, y: height - pointHeight), control: CGPoint(x: width, y: height - pointHeight))
                path.addLine(to: bottomRight)
                path.addLine(to: bottomPoint)
                path.addLine(to: bottomLeft)
                path.addLine(to: CGPoint(x: radius, y: height - pointHeight))
                path.addQuadCurve(to: CGPoint(x: 0, y: height - pointHeight - radius), control: CGPoint(x: 0, y: height - pointHeight))
                path.addLine(to: CGPoint(x: 0, y: radius))
                path.closeSubpath()
            }
            .fill(Color.white)
        }
        .frame(width: 200, height: 120)
    }
    
    private var blackCircularButton: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 80, height: 80)
            
            VStack(spacing: 6) {
                Text(text)
                    .font(.spaceGrotesk(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                arrowIcon
            }
        }
        .offset(y: -25)
    }
    
    private var arrowIcon: some View {
        Group {
            if let url = Bundle.main.url(forResource: "arrow", withExtension: "svg", subdirectory: nil) ??
                         Bundle.main.url(forResource: "arrow", withExtension: "svg", subdirectory: "Assets/Images") {
                SVGWebView(url: url, maxWidth: 20, maxHeight: 20)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
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

