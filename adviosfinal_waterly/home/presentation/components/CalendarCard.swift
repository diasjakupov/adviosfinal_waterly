//
//  CalendarCard.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//

import SwiftUI

struct CalendarCard: View {
    let day: DayStub
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(day.date, format: .dateTime.weekday())
                    .font(.subheadline).foregroundColor(.white)
                Text(day.date, format: .dateTime.day())
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                Text(day.date, format: .dateTime.month(.abbreviated))
                    .font(.title3).bold().foregroundColor(.white)
            }
            Spacer(minLength: 32)
            
            VStack(alignment: .trailing, spacing: 12) {
                ForEach(day.groups, id: \.name) { g in
                    HStack(spacing: 8) {
                        Text(g.name)
                            .foregroundColor(.white)
                        badge(g.count)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.wCard)
        .cornerRadius(24)
    }
    
    @ViewBuilder
    private func badge(_ n: Int) -> some View {
        Text(String(n))
            .font(.caption2).bold().foregroundColor(.white)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Capsule().fill(Color.wBadge))
    }
}
