import Foundation

final class RestoreGoogleSignInUseCase {
    private let repository: SettingsRepository
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute() async -> String? {
        await repository.restorePreviousSignIn()
    }
} 