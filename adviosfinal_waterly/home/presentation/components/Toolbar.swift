//
//  Toolbar.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct Toolbar: View {
    var selected: TimeTab
    var onSettingsClick: () -> Void
    var onAnalyticsClick: () -> Void
    var onTabSelect: (TimeTab) -> Void      
    
    var body: some View {
        HStack(spacing: 12) {
            pill("Today",    tab: .today)
            pill("Calendar", tab: .calendar)
            Spacer()
            Button(action: onAnalyticsClick) {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            Button(action: onSettingsClick) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
    }
    
    @ViewBuilder
    private func pill(_ text: String, tab: TimeTab) -> some View {
        let isOn = tab == selected
        Button { onTabSelect(tab) } label: {
            Text(text).fontWeight(.semibold)
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
