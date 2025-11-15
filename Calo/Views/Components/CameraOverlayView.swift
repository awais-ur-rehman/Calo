//
//  CameraOverlayView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct CameraOverlayView: View {
    let onCapture: () -> Void
    let onGalleryTap: () -> Void
    let isProcessing: Bool
    @State private var selectedMode: CameraMode = .camera
    
    enum CameraMode {
        case camera
        case gallery
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                cameraModeButton
                
                Spacer()
                
                captureButton
                
                Spacer()
                
                galleryButton
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private var cameraModeButton: some View {
        Button(action: {
            selectedMode = .camera
        }) {
            VStack(spacing: 8) {
                if let url = Bundle.main.url(forResource: "camera", withExtension: "svg", subdirectory: nil) ??
                             Bundle.main.url(forResource: "camera", withExtension: "svg", subdirectory: "Assets/Images") {
                    SVGWebView(url: url, maxWidth: 24, maxHeight: 24)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedMode == .camera ? .black : .white)
                }
                
                Text("AI Camera")
                    .font(.spaceGrotesk(size: 14, weight: .medium))
                    .foregroundColor(selectedMode == .camera ? .black : .white)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(selectedMode == .camera ? Color.white : Color.clear)
            .cornerRadius(8)
        }
    }
    
    private var captureButton: some View {
        Button(action: onCapture) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .stroke(Color.black, lineWidth: 4)
                    .frame(width: 64, height: 64)
                
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
        }
        .disabled(isProcessing)
    }
    
    private var galleryButton: some View {
        Button(action: {
            selectedMode = .gallery
            onGalleryTap()
        }) {
            VStack(spacing: 8) {
                if let url = Bundle.main.url(forResource: "gallery", withExtension: "svg", subdirectory: nil) ??
                             Bundle.main.url(forResource: "gallery", withExtension: "svg", subdirectory: "Assets/Images") {
                    SVGWebView(url: url, maxWidth: 24, maxHeight: 24)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20))
                        .foregroundColor(selectedMode == .gallery ? .black : .white)
                }
                
                Text("Gallery")
                    .font(.spaceGrotesk(size: 14, weight: .medium))
                    .foregroundColor(selectedMode == .gallery ? .black : .white)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(selectedMode == .gallery ? Color.white : Color.clear)
            .cornerRadius(8)
        }
    }
}

#Preview {
    CameraOverlayView(onCapture: {}, onGalleryTap: {}, isProcessing: false)
        .background(Color.black.opacity(0.3))
}

