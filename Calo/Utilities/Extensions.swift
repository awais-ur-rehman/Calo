//
//  Extensions.swift
//  Calo
//
//  Created by flash on 11/14/25.
//

import Foundation
import SwiftUI

extension String {
    func formattedFoodName() -> String {
        self.replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Font {
    static func spaceGrotesk(size: CGFloat, weight: SpaceGroteskWeight = .regular) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
}

enum SpaceGroteskWeight {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    var fontName: String {
        switch self {
        case .light:
            return "SpaceGrotesk-Light"
        case .regular:
            return "SpaceGrotesk-Regular"
        case .medium:
            return "SpaceGrotesk-Medium"
        case .semibold:
            return "SpaceGrotesk-SemiBold"
        case .bold:
            return "SpaceGrotesk-Bold"
        }
    }
}

