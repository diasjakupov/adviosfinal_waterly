//
//  AddTaskUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class AddTaskUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) {
        self.repository = repository
    }
    
    func execute(_ task: TaskModel) async throws {
        try await repository.add(task)
    }
} 
