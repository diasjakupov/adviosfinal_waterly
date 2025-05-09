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
