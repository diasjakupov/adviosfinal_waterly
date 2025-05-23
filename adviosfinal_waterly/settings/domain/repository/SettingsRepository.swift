//
//  SettingsRepository.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation
import UIKit

protocol SettingsRepository {
    func connectGoogleCalendar(presentingViewController: UIViewController) async throws -> String?
    func restorePreviousSignIn() async -> String?
    func currentUserEmail() -> String?
    func disconnectGoogleCalendar()
    func syncAllTasksToGoogleCalendar(tasks: [TaskModel]) async throws -> [UUID: String]
    func toggleNotifications(_ isOn: Bool, completion: @escaping (Bool, Bool) -> Void)
}

protocol GoogleCalendarRepository {
    func updateTask(_ task: TaskModel) async throws
    func deleteTask(_ task: TaskModel) async throws
} 
