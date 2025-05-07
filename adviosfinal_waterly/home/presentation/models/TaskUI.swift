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
    
    /// Convert a domain model into the colourful UI model,
    /// cycling through sample palettes by `index`.
    static func toUi(_ m: TaskModel, index i: Int) -> TaskUI {
        // sample palettes — same as Android version
        let palettes: [(Color, Color, Color)] = [
            (.init(red:0.85,green:0.80,blue:0.78), .init(red:0.24,green:0.15,blue:0.14), .init(red:0.36,green:0.25,blue:0.22)),
            (.init(red:0.66,green:0.69,blue:0.70), .init(red:0.23,green:0.28,blue:0.28), .init(red:0.23,green:0.28,blue:0.28)),
            (.init(red:0.78,green:0.90,blue:0.79), .init(red:0.11,green:0.37,blue:0.13), .init(red:0.18,green:0.49,blue:0.20)),
            (.init(red:1.00,green:0.98,blue:0.77), .init(red:0.96,green:0.50,blue:0.09), .init(red:0.98,green:0.66,blue:0.15))
        ]
        let (bg, titleCol, chipCol) = palettes[i % palettes.count]
        
        // time ⇢ string
        let tFmt = DateFormatter()
        tFmt.dateFormat = "HH:mm"
        let s = tFmt.string(from: m.startTime)
        let e = tFmt.string(from: m.endTime)
        let dur = timeLabel(m.startTime, m.endTime)
        
        return TaskUI(
            id: m.id,
            title: m.title,
            start: s,
            end: e,
            duration: dur,
            bg: bg,
            titleColor: titleCol,
            chipColor: chipCol,
            status:m.status
        )
    }
    
    // returns “1h 15m” etc.
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
