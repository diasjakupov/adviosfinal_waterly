//
//  Task.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//


import SwiftUI

struct TaskUI: Identifiable {
    let id: UUID
    let title: String
    let start: String
    let end  : String
    let duration: String
    let bg : Color
    let titleColor: Color
    let chipColor : Color
    var status: TaskStatus
}



enum TaskModelMapper {
    static func toUi(_ model: TaskModel, index i: Int) -> TaskUI {
        let palettes: [(Color, Color, Color)] = [
            (.taskPalette1Bg, .taskPalette1Title, .taskPalette1Chip),
            (.taskPalette2Bg, .taskPalette2Title, .taskPalette2Chip),
            (.taskPalette3Bg, .taskPalette3Title, .taskPalette3Chip),
            (.taskPalette4Bg, .taskPalette4Title, .taskPalette4Chip)
        ]
        let (bg, titleCol, chipCol) = palettes[i % palettes.count]
        
        let tFmt = DateFormatter()
        tFmt.dateFormat = "HH:mm"
        let start = tFmt.string(from: model.startTime)
        let end = tFmt.string(from: model.endTime)
        let dur = timeLabel(model.startTime, model.endTime)
        
        return TaskUI(
            id: model.id,
            title: model.title,
            start: start,
            end: end,
            duration: dur,
            bg: bg,
            titleColor: titleCol,
            chipColor: chipCol,
            status:model.status
        )
    }
    
    // returns "1h 15m" etc.
    private static func timeLabel(_ start: Date, _ end: Date) -> String {
        let min = Int(end.timeIntervalSince(start) / 60)
        if min >= 60 {
            let h = min / 60, m = min % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        } else {
            return "\(min) Min"
        }
    }
}
