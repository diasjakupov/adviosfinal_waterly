//
//  UpdateTaskStatusUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class UpdateTaskStatusUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID, status: TaskStatus) async throws {
        try await repository.updateStatus(id: id, to: status)
    }
} 
