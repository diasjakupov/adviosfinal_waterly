//
//  StickyHeader.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

internal struct StickyHeader: View {
    let date: Date
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            Text(date.formatted(date: .abbreviated, time: .omitted).uppercased())
                .font(.caption).padding(.leading, 8)
        }
    }
}
