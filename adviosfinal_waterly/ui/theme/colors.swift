//
//  colors.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

extension Color {
    static let wBackground = Color(red: 0.063, green: 0.106, blue: 0.173) // #101B28
    static let wSurface    = Color(red: 0.078, green: 0.141, blue: 0.235) // #14243C
    static let wBlue       = Color(red: 0.392, green: 0.714, blue: 0.965) // #64B5F6
    static let wBlueLight  = Color(red: 0.733, green: 0.871, blue: 0.984) // #BBDEFB
    static let wGreyLight  = Color.white.opacity(0.7)
    static let wBorder   = Color.wBlue
    static let wGreyText = Color.white.opacity(0.65)
    static let wCard   = Color.wSurface
    static let wBadge  = Color.wBlue

    // Task Palettes
    static let taskPalette1Bg      = Color(red:0.85,green:0.80,blue:0.78)
    static let taskPalette1Title   = Color(red:0.24,green:0.15,blue:0.14)
    static let taskPalette1Chip    = Color(red:0.36,green:0.25,blue:0.22)

    static let taskPalette2Bg      = Color(red:0.66,green:0.69,blue:0.70)
    static let taskPalette2Title   = Color(red:0.23,green:0.28,blue:0.28)
    static let taskPalette2Chip    = Color(red:0.23,green:0.28,blue:0.28)

    static let taskPalette3Bg      = Color(red:0.78,green:0.90,blue:0.79)
    static let taskPalette3Title   = Color(red:0.11,green:0.37,blue:0.13)
    static let taskPalette3Chip    = Color(red:0.18,green:0.49,blue:0.20)

    static let taskPalette4Bg      = Color(red:1.00,green:0.98,blue:0.77)
    static let taskPalette4Title   = Color(red:0.96,green:0.50,blue:0.09)
    static let taskPalette4Chip    = Color(red:0.98,green:0.66,blue:0.15)
}
