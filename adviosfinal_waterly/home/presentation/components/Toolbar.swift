//
//  Toolbar.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

internal struct PillButton: View {
    var text: String
    var isOn: Bool
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(isOn ? .white : .wBlue)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(isOn ? Color.wBlue : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.wBlue, lineWidth: 1)
                )
        }
        .animation(.easeInOut, value: isOn)
    }
}
