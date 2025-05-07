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
}
