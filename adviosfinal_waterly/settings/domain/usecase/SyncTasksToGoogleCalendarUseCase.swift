//
//  SyncTasksToGoogleCalendarUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class SyncTasksToGoogleCalendarUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute(tasks: [TaskModel]) async throws {
        try await repository.syncAllTasksToGoogleCalendar(tasks: tasks)
    }
} 
