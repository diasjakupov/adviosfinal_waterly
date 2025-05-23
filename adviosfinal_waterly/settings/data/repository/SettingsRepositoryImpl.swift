//
//  SettingsRepositoryImpl.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation
import UIKit
import UserNotifications

final class SettingsRepositoryImpl: SettingsRepository {
    private let googleDataSource: GoogleCalendarRemoteDataSource
    
    init(googleDataSource: GoogleCalendarRemoteDataSource = .shared) {
        self.googleDataSource = googleDataSource
    }
    
    func connectGoogleCalendar(presentingViewController: UIViewController) async throws -> String? {
        let user = try await googleDataSource.signIn(presentingViewController: presentingViewController)
        return user.profile?.email
    }
    
    func restorePreviousSignIn() async -> String? {
        let user = await googleDataSource.restorePreviousSignIn()
        return user?.profile?.email
    }
    
    func currentUserEmail() -> String? {
        googleDataSource.currentUserEmail()
    }
    
    func disconnectGoogleCalendar() {
        googleDataSource.signOut()
    }
    
    func syncAllTasksToGoogleCalendar(tasks: [TaskModel]) async throws -> [UUID: String] {
        try await googleDataSource.addTasksToCalendar(tasks: tasks)
    }
    
    func toggleNotifications(_ isOn: Bool, completion: @escaping (Bool, Bool) -> Void) {
        if isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted, !granted)
                }
            }
        } else {
            completion(false, false)
        }
    }
}

extension SettingsRepositoryImpl: GoogleCalendarRepository {
    func updateTask(_ task: TaskModel) async throws {
        try await googleDataSource.updateTask(task)
    }
    func deleteTask(_ task: TaskModel) async throws {
        try await googleDataSource.deleteTask(task)
    }
} 
