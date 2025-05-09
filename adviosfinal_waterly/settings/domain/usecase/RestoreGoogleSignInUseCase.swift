//
//  RestoreGoogleSignInUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

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
