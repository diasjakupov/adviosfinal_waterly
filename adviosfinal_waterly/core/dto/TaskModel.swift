//
//  TaskModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//

import CoreData
import Foundation


enum TaskStatus: String, Codable, CaseIterable {
    case created = "Created"
    case done    = "Done"
}


struct TaskModel {
    var id: UUID         = .init()
    var title: String
    var date: Date
    var startTime: Date
    var endTime:   Date
    var notes: String
    var category: String?
    var repeatRule: RepeatRule
    var status: TaskStatus  = .created
    var eventId: String? = nil
    var eventIds: [String]? = nil      
}
