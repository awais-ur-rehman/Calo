//
//  SVGWebView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI
import WebKit

struct SVGWebView: UIViewRepresentable {
    let url: URL
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    
    init(url: URL, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) {
        self.url = url
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if let data = try? Data(contentsOf: url),
           let svgString = String(data: data, encoding: .utf8) {
            let maxWidthStr = maxWidth != nil ? "max-width: \(Int(maxWidth!))px;" : ""
            let maxHeightStr = maxHeight != nil ? "max-height: \(Int(maxHeight!))px;" : ""
            
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
                        \(maxWidthStr)
                        \(maxHeightStr)
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

