//
//  UpdateTaskUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//

import Foundation

final class UpdateTaskUseCase {
    private let repository: TaskRepository
    private let googleRepository: GoogleCalendarRepository
    init(repository: TaskRepository, googleRepository: GoogleCalendarRepository) {
        self.repository = repository
        self.googleRepository = googleRepository
    }
    func execute(_ task: TaskModel) async throws {
        try await repository.update(task)
        try await googleRepository.updateTask(task)
    }
} 