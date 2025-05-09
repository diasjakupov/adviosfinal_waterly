//
//  UpdateHomeTaskStatusUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class UpdateHomeTaskStatusUseCase {
    private let repository: HomeRepository
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID, status: TaskStatus) async throws {
        try await repository.updateStatus(id: id, to: status)
    }
} 
