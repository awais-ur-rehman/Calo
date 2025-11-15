//
//  ImagePreprocessor.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import UIKit
import CoreML
import Vision

class ImagePreprocessor {
    static let shared = ImagePreprocessor()
    
    private let targetSize = CGSize(width: Constants.ML.inputImageSize, height: Constants.ML.inputImageSize)
    
    private init() {}
    
    func preprocessImage(_ image: UIImage) throws -> CVPixelBuffer {
        guard let pixelBuffer = image.pixelBuffer(width: Int(targetSize.width), height: Int(targetSize.height)) else {
            throw CaloError.invalidImage
        }
        return pixelBuffer
    }
}

extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgContext = context else {
            return nil
        }
        
        cgContext.interpolationQuality = .high
        cgContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
    }
}

