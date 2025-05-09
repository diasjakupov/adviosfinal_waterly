//
//  SyncTaskToGoogleCalendarUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation

final class SyncTaskToGoogleCalendarUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }

    func execute(task: TaskModel) async throws {
        try await repository.syncAllTasksToGoogleCalendar(tasks: [task])
    }
} 
