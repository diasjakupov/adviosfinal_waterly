//
//  Task.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//


import SwiftUI

enum TimeOption: String, CaseIterable { case today="Today", calendar="Calendar" }

enum TaskStatus { case created, done }

struct Task: Identifiable {
    let id  = UUID()
    let title: String
    let start: String
    let end  : String
    let duration: String
    let bg : Color
    let titleColor: Color
    let chipColor : Color
}
