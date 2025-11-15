//
//  CameraOverlayView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI

struct CameraOverlayView: View {
    let onCapture: () -> Void
    let isProcessing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
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
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    CameraOverlayView(onCapture: {}, isProcessing: false)
        .background(Color.black.opacity(0.3))
}

