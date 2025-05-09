import Foundation

final class ToggleNotificationsUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute(isOn: Bool, completion: @escaping (Bool, Bool) -> Void) {
        repository.toggleNotifications(isOn, completion: completion)
    }
} 