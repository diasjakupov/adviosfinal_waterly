//
//  HomeViewModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var tab: TimeTab = .today
    @Published var today: [TaskModel] = []
    @Published var grouped: [Date:[TaskModel]] = [:]
    @Published var doneFraction: CGFloat = 0
    @Published var allTasks: [TaskModel] = [] 
    @Published var error: String? = nil

    private let getTaskStreamUseCase: GetTaskStreamUseCase
    private let updateTaskStatusUseCase: UpdateHomeTaskStatusUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private var streamTask: Task<Void, Never>? = nil

    var calendarDays: [DayStub] {
        grouped.keys.sorted().map { date in
            let tasks = grouped[date] ?? []
            let categoryCounts = Dictionary(grouping: tasks) { $0.category ?? "Other" }
                .map { (name: $0.key, count: $0.value.count) }
            return DayStub(date: date, groups: categoryCounts)
        }
    }
    
    public init(
        getTaskStreamUseCase: GetTaskStreamUseCase,
        updateTaskStatusUseCase: UpdateHomeTaskStatusUseCase,
        deleteTaskUseCase: DeleteTaskUseCase
    ) {
        self.getTaskStreamUseCase = getTaskStreamUseCase
        self.updateTaskStatusUseCase = updateTaskStatusUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        listen()
    }
    
    func setStatus(of id: UUID, to s: TaskStatus) {
        Task {
            do {
                try await updateTaskStatusUseCase.execute(id: id, status: s)
                self.error = nil
            } catch {
                self.error = error.localizedDescription.isEmpty ? "Failed to update task status. Please try again." : error.localizedDescription
            }
        }
    }
    
    private func listen() {
        streamTask = Task {
            do {
                for try await list in getTaskStreamUseCase.execute() {
                    update(with: list)
                    self.error = nil
                }
            } catch {
                print("Error in taskStream: \(error)")
                self.error = error.localizedDescription.isEmpty ? "Failed to load tasks. Please try again." : error.localizedDescription
            }
        }
    }
    
    private func update(with list:[TaskModel]) {
        let cal = Calendar.current
        grouped = Dictionary(grouping:list){ cal.startOfDay(for:$0.date) }
        today   = list.filter{ cal.isDateInToday($0.date) }
        let done = today.filter { $0.status == .done }.count
        doneFraction = today.isEmpty ? 0 : CGFloat(done)/CGFloat(today.count)
        allTasks = list
    }
    
    /* UI helpers */
    public func switchTab(_ t:TimeTab){ tab = t }

    func findTaskModel(by id: UUID) -> TaskModel? {
        allTasks.first { $0.id == id }
    }

    func deleteTask(_ task: TaskModel) async throws {
        try await deleteTaskUseCase.execute(task)
    }
}
