//
//  TodaysSection.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

internal struct TodayTasksSection: View {
    var tasks: [TaskUI]
    var onTap: (TaskUI) -> Void           // pass tap up to HomeScreen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's tasks")
                .font(.title2).bold().foregroundColor(.white)
            
            ScrollView {                                // ① scrolls
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { t in
                        TaskCard(task: t)
                            .onTapGesture { onTap(t) } // ② bubble tap
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal)
    }
}

internal struct TaskCard: View {
    var task: TaskUI
    var body: some View {
        VStack(alignment:.leading,spacing:8) {
            Text(task.title)
                .font(.title3).bold()
                .foregroundColor(task.titleColor)
                .strikethrough(task.status == .done)
            HStack {
                VStack(alignment:.leading,spacing:4) {
                    Text("Start").font(.caption).foregroundColor(.primary.opacity(0.6))
                    Text(task.start).bold()
                }
                Spacer()
                RoundedRectangle(cornerRadius:18)
                    .fill(task.chipColor)
                    .overlay(Text(task.duration).font(.caption).foregroundColor(.white))
                    .frame(width:80,height:28)
                Spacer()
                VStack(alignment:.trailing,spacing:4) {
                    Text("End").font(.caption).foregroundColor(.primary.opacity(0.6))
                    Text(task.end).bold()
                }
            }
        }
        .padding()
        .background(task.bg)
        .cornerRadius(20)
    }
}
