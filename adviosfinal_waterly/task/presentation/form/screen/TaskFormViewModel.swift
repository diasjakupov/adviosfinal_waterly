//
//  TaskFormViewModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import SwiftUI
import Combine

@MainActor
final class TaskFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var date  = Date()
    @Published var start = Date()
    @Published var end   = Date()
    @Published var notes = ""
    @Published var repeatRule: RepeatRule = .none
    
    @Published var categories: [String] = []
    @Published var selected: String? = nil
    @Published var saved = false
    @Published var error: String?
    
    private let repo: TaskRepository
    
    
    init(repo: TaskRepository = DefaultTaskRepository()) {
        self.repo = repo
        Task { categories = try await repo.categories() }
    }
    
    func addCat(_ n:String) {
        selected = n
        if !categories.contains(n) { categories.append(n) }
    }
    
    func save() {
        guard !title.isEmpty else { error="Title required"; return }
        Task{
            do {
                try await repo.add(
                    TaskModel(title:title,date:date,startTime:start,endTime:end,
                              notes:notes,category:selected,repeatRule:repeatRule)
                )
                saved = true
            } catch { self.error = error.localizedDescription }
        }
    }
}
