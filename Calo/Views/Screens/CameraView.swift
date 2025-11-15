//
//  CameraView.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var capturedImage: UIImage?
    @State private var shouldNavigateToResults = false
    
    let onFoodScanned: (FoodItem) -> Void
    
    var body: some View {
        ZStack {
            if viewModel.permissionStatus == .authorized {
                cameraPreview
            } else {
                permissionView
            }
            
            NavigationLink(
                destination: Group {
                    if let image = capturedImage {
                        ProcessingResultView(
                            viewModel: viewModel,
                            capturedImage: image,
                            onFoodScanned: { foodItem in
                                onFoodScanned(foodItem)
                                resetState()
                            },
                            onRetake: {
                                resetState()
                            }
                        )
                    } else {
                        EmptyView()
                    }
                },
                isActive: $shouldNavigateToResults
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationTitle("AI Camera")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            Task {
                if viewModel.permissionStatus == .notDetermined {
                    await viewModel.requestPermission()
                } else if viewModel.permissionStatus == .authorized {
                    await viewModel.startSession()
                }
            }
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.capturedImage) { oldValue, newValue in
            print("📸 [CameraView] onChange triggered - oldValue: \(oldValue != nil ? "has image" : "nil"), newValue: \(newValue != nil ? "has image" : "nil")")
            if let image = newValue {
                print("📸 [CameraView] Image captured, setting state and navigating...")
                capturedImage = image
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("📸 [CameraView] Activating navigation link...")
                    shouldNavigateToResults = true
                }
            }
        }
        .onChange(of: shouldNavigateToResults) { oldValue, newValue in
            print("📸 [CameraView] shouldNavigateToResults changed: \(oldValue) -> \(newValue)")
        }
    }
    
    private func resetState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            capturedImage = nil
            shouldNavigateToResults = false
            viewModel.predictions = []
            viewModel.selectedPrediction = nil
            viewModel.error = nil
            viewModel.capturedImage = nil
        }
    }
    
    private var cameraPreview: some View {
        ZStack {
            CameraPreview(session: viewModel.cameraService.session)
                .ignoresSafeArea()
            
            captureOverlay
        }
    }
    
    private var captureOverlay: some View {
        CameraOverlayView(
            onCapture: {
                viewModel.capturePhoto()
            },
            onGalleryTap: {
                // TODO: Implement gallery picker
            },
            isProcessing: false
        )
    }
    
    
    private var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Camera Permission Required")
                .font(.headline)
            
            Text("We need camera access to scan and identify food items.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Grant Permission") {
                Task {
                    await viewModel.requestPermission()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
        }
        .padding()
    }
    
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = getVideoOrientation()
        view.layer.insertSublayer(previewLayer, at: 0)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = context.coordinator.previewLayer {
                previewLayer.frame = uiView.bounds
                previewLayer.connection?.videoOrientation = getVideoOrientation()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func getVideoOrientation() -> AVCaptureVideoOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .portrait
        }
        
        let orientation = windowScene.interfaceOrientation
        
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

#Preview {
    CameraView(onFoodScanned: { _ in })
}

