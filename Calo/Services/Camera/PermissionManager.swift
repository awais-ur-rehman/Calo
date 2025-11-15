//
//  PermissionManager.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import AVFoundation

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    func checkCameraPermission() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    var isCameraAuthorized: Bool {
        checkCameraPermission() == .authorized
    }
}

