import Foundation

final class DisconnectGoogleCalendarUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute() {
        repository.disconnectGoogleCalendar()
    }
} 