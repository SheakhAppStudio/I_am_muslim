//
//  IslamicTheme.swift
//  I am Muslim Watch App Watch App
//
//  Created by Cascade AI on 25/04/2025.
//

import SwiftUI

struct IslamicTheme {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(hex: "1F4B6B"),
            Color(hex: "366C8F")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [
            Color(hex: "FFFFFF"),
            Color(hex: "F7F9FC")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let accentColor = Color(hex: "C3934B") // Gold accent
    static let textColor = Color(hex: "1A1A1A")
    static let subtleText = Color(hex: "6B7280")
    
    static let cardBackground = Color(hex: "FFFFFF").opacity(0.95)
    static let shadowColor = Color.black.opacity(0.1)
    
    // Prayer time status colors
    static let upcomingPrayer = Color(hex: "4B956F")
    static let pastPrayer = Color(hex: "6B7280")
    
    // Custom shapes
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
}

// Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
