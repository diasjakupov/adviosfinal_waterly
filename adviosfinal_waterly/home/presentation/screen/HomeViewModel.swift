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
    
    private let repo: HomeRepository
    private var streamTask: Task<Void, Never>? = nil
    
    public init(repo: HomeRepository) {
        self.repo = repo
        listen()
    }
    
    
    func setStatus(of id: UUID, to s: TaskStatus) {
        Task { try? await repo.updateStatus(id: id, to: s) }
    }
    
    private func listen() {
        streamTask = Task {
            do {
                for try await list in repo.taskStream() {
                    print("------------------")
                    print("items: \(list)")
                    update(with: list)
                }
            } catch {
                print("Error in taskStream: \(error)")
            }
        }
    }
    
    
    private func update(with list:[TaskModel]) {
        let cal = Calendar.current
        grouped = Dictionary(grouping:list){ cal.startOfDay(for:$0.date) }
        today   = list.filter{ cal.isDateInToday($0.date) }
        let done = today.filter { $0.status == .done }.count
        doneFraction = today.isEmpty ? 0 : CGFloat(done)/CGFloat(today.count)
    }
    
    /* UI helpers */
    public func switchTab(_ t:TimeTab){ tab = t }
}
