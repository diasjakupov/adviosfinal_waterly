import Foundation
import UIKit

final class ConnectGoogleCalendarUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute(presentingViewController: UIViewController) async throws -> String? {
        return try await repository.connectGoogleCalendar(presentingViewController: presentingViewController)
    }
} 