//
//  CalendarSheetState.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import Foundation

import SwiftUI

enum CalendarSheetState: Identifiable, Equatable {
    case date(Date)
    case task(TaskUI)

    var id: String {
        switch self {
        case .date(let date):
            return "date-\(date.timeIntervalSince1970)"
        case .task(let task):
            return "task-\(task.id)"
        }
    }

    static func == (lhs: CalendarSheetState, rhs: CalendarSheetState) -> Bool {
        switch (lhs, rhs) {
        case let (.date(ld), .date(rd)): return ld == rd
        case let (.task(lt), .task(rt)): return lt.id == rt.id
        default: return false
        }
    }
} 