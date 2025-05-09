//
//  ToggleNotificationsUseCase.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

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
