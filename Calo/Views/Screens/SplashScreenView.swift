//
//  SplashScreenView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI
import WebKit

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
                        .font(.system(size: 64, weight: .bold))
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
            Text("Eating")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                Text("Healthy")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "45C588"))
                    .cornerRadius(20)
                
                Text("made easy!")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
            }
        }
        .multilineTextAlignment(.center)
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
                SVGWebView(url: url)
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

struct SVGWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if let data = try? Data(contentsOf: url),
           let svgString = String(data: data, encoding: .utf8) {
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    body {
                        margin: 0;
                        padding: 0;
                        background-color: transparent;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                    }
                    svg {
                        width: 100%;
                        height: 100%;
                        max-width: 420px;
                        max-height: 336px;
                    }
                </style>
            </head>
            <body>
                \(svgString)
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: url.deletingLastPathComponent())
        }
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}

#Preview {
    SplashScreenView()
}

