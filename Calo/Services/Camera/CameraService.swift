//
//  CameraService.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import AVFoundation
import UIKit

@MainActor
class CameraService: NSObject, ObservableObject {
    static let shared = CameraService()
    
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?
    @Published var error: CaloError?
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoInput: AVCaptureDeviceInput?
    private let permissionManager = PermissionManager.shared
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
    }
    
    private func setupSession() async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }
                
                if self.session.isRunning {
                    self.session.stopRunning()
                }
                
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                
                if let existingInput = self.videoInput {
                    self.session.removeInput(existingInput)
                }
                
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    self.session.commitConfiguration()
                    Task { @MainActor in
                        self.error = .cameraUnavailable
                    }
                    continuation.resume(returning: false)
                    return
                }
                
                do {
                    try videoDevice.lockForConfiguration()
                    defer { videoDevice.unlockForConfiguration() }
                    
                    let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    if self.session.canAddInput(videoInput) {
                        self.session.addInput(videoInput)
                        self.videoInput = videoInput
                    } else {
                        self.session.commitConfiguration()
                        Task { @MainActor in
                            self.error = .cameraUnavailable
                        }
                        continuation.resume(returning: false)
                        return
                    }
                    
                    if self.session.canAddOutput(self.photoOutput) {
                        self.session.addOutput(self.photoOutput)
                    }
                    
                    self.session.commitConfiguration()
                    continuation.resume(returning: true)
                } catch {
                    self.session.commitConfiguration()
                    Task { @MainActor in
                        self.error = .cameraUnavailable
                    }
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func startSession() async {
        guard permissionManager.isCameraAuthorized else {
            error = .cameraPermissionDenied
            return
        }
        
        if await !isSessionConfigured() {
            let setupSuccess = await setupSession()
            if !setupSuccess {
                return
            }
        }
        
        await startSessionInternal()
    }
    
    private func isSessionConfigured() async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                let hasInput = self?.videoInput != nil
                continuation.resume(returning: hasInput)
            }
        }
    }
    
    private func startSessionInternal() async {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                guard !self.session.isRunning else {
                    Task { @MainActor in
                        self.isSessionRunning = true
                    }
                    continuation.resume()
                    return
                }
                
                self.session.startRunning()
                
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
                
                continuation.resume()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
                
                Task { @MainActor in
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func capturePhoto() {
        print("📷 [CameraService] capturePhoto() called")
        guard isSessionRunning else {
            print("❌ [CameraService] Session is not running (isSessionRunning=false)")
            Task { @MainActor in
                self.error = .cameraUnavailable
            }
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else {
                print("❌ [CameraService] Self is nil in capturePhoto")
                return
            }
            
            print("📷 [CameraService] Session isRunning: \(self.session.isRunning)")
            guard self.session.isRunning else {
                print("❌ [CameraService] Session is not running")
                Task { @MainActor in
                    self.error = .cameraUnavailable
                }
                return
            }
            
            let photoOutput = self.photoOutput
            
            print("📷 [CameraService] photoOutput connections: \(photoOutput.connections.count)")
            guard photoOutput.connections.count > 0 else {
                print("❌ [CameraService] No photo output connections")
                Task { @MainActor in
                    self.error = .cameraUnavailable
                }
                return
            }
            
            let settings = AVCapturePhotoSettings()
            
            if photoOutput.isHighResolutionCaptureEnabled {
                settings.isHighResolutionPhotoEnabled = true
            }
            
            if photoOutput.isStillImageStabilizationSupported {
                settings.isAutoStillImageStabilizationEnabled = true
            }
            
            if let connection = photoOutput.connection(with: .video) {
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = false
                }
            }
            
            print("📷 [CameraService] Calling photoOutput.capturePhoto()...")
            photoOutput.capturePhoto(with: settings, delegate: self)
            print("📷 [CameraService] capturePhoto() call completed")
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📷 [CameraService] didFinishProcessingPhoto called")
        
        if let error = error {
            print("❌ [CameraService] Photo processing error: \(error.localizedDescription)")
            Task { @MainActor in
                self.error = .predictionFailed(error.localizedDescription)
            }
            return
        }
        
        print("📷 [CameraService] Getting fileDataRepresentation...")
        guard let imageData = photo.fileDataRepresentation() else {
            print("❌ [CameraService] Failed to get imageData from photo")
            Task { @MainActor in
                self.error = .invalidImage
            }
            return
        }
        
        print("📷 [CameraService] Image data size: \(imageData.count) bytes")
        
        guard let image = UIImage(data: imageData) else {
            print("❌ [CameraService] Failed to create UIImage from data")
            Task { @MainActor in
                self.error = .invalidImage
            }
            return
        }
        
        print("📷 [CameraService] UIImage created successfully, size: \(image.size)")
        
        Task { @MainActor in
            print("📷 [CameraService] Setting capturedImage on main actor...")
            self.capturedImage = image
            print("📷 [CameraService] capturedImage set to: \(image.size)")
        }
    }
    
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("📷 [CameraService] didFinishCaptureFor called")
        if let error = error {
            print("❌ [CameraService] Capture finished with error: \(error.localizedDescription)")
            Task { @MainActor in
                self.error = .predictionFailed(error.localizedDescription)
            }
        } else {
            print("✅ [CameraService] Capture finished successfully")
        }
    }
}

