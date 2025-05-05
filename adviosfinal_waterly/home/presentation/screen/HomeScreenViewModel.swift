//
//  HomeScreenViewModel.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI


//private let sampleTasks: [Task] = [
//    Task(title:"You Have A Meeting", start:"3:00 PM", end:"3:30 PM",
//         duration:"30 Min",
//         bg: Color(red:0.85,green:0.80,blue:0.78),
//         titleColor: Color(red:0.24,green:0.15,blue:0.14),
//         chipColor: Color(red:0.36,green:0.25,blue:0.22)),
//    Task(title:"You Have A Meeting", start:"4:00 PM", end:"4:30 PM",
//         duration:"30 Min",
//         bg: Color(red:0.66,green:0.69,blue:0.70),
//         titleColor: Color(red:0.23,green:0.28,blue:0.28),
//         chipColor: Color(red:0.23,green:0.28,blue:0.28))
//]
//
//@MainActor
//final class HomeScreenViewModel: ObservableObject {
//    @Published var tasks: [Task] = sampleTasks
//    @Published var selected: TimeOption = .today
//    
//    var doneFraction: CGFloat {
//        let today = Calendar.current.isDateInToday
//        let todays = tasks.filter { today($0.date) }
//        guard !todays.isEmpty else { return 0 }
//        let done = todays.filter { $0.status == .done }.count
//        return CGFloat(done) / CGFloat(todays.count)
//    }
//    
//    // grouped for Calendar
//    var tasksByDate: [Date: [Task]] {
//        Dictionary(grouping: tasks) { Calendar.current.startOfDay(for: $0.date) }
//            .mapValues { $0.sorted { $0.start < $1.start } }
//            .sorted { $0.key < $1.key }
//            .reduce(into: [:]) { $0[$1.key] = $1.value }
//    }
//    
//    func toggle(_ task: Task) {
//        guard let idx = tasks.firstIndex(of: task) else { return }
//        tasks[idx].status = (task.status == .done ? .created : .done)
//    }
//}
