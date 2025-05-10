//
//  SettingsViewModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//


import SwiftUI
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notifEnabled: Bool = false
    @Published var permissionDenied: Bool = false
    @Published var isGoogleConnected: Bool = false
    @Published var googleUserEmail: String? = nil
    @Published var googleAuthError: String? = nil
    @Published var syncStatus: String = ""

    private let connectGoogleCalendarUseCase: ConnectGoogleCalendarUseCase
    private let disconnectGoogleCalendarUseCase: DisconnectGoogleCalendarUseCase
    private let syncTasksToGoogleCalendarUseCase: SyncTasksToGoogleCalendarUseCase
    private let toggleNotificationsUseCase: ToggleNotificationsUseCase
    private let restoreGoogleSignInUseCase: RestoreGoogleSignInUseCase
    private let allTasks: [TaskModel]

    init(
        connectGoogleCalendarUseCase: ConnectGoogleCalendarUseCase,
        disconnectGoogleCalendarUseCase: DisconnectGoogleCalendarUseCase,
        syncTasksToGoogleCalendarUseCase: SyncTasksToGoogleCalendarUseCase,
        toggleNotificationsUseCase: ToggleNotificationsUseCase,
        restoreGoogleSignInUseCase: RestoreGoogleSignInUseCase,
        allTasks: [TaskModel]
    ) {
        self.connectGoogleCalendarUseCase = connectGoogleCalendarUseCase
        self.disconnectGoogleCalendarUseCase = disconnectGoogleCalendarUseCase
        self.syncTasksToGoogleCalendarUseCase = syncTasksToGoogleCalendarUseCase
        self.toggleNotificationsUseCase = toggleNotificationsUseCase
        self.restoreGoogleSignInUseCase = restoreGoogleSignInUseCase
        self.allTasks = allTasks
        Task { await self.restoreGoogleSignInIfNeeded() }
    }


    func toggleNotifications(_ isOn: Bool) {
        toggleNotificationsUseCase.execute(isOn: isOn) { [weak self] granted, denied in
            guard let self = self else { return }
            self.notifEnabled = granted
            self.permissionDenied = denied
        }
    }

    func connectGoogleCalendar(presentingViewController: UIViewController) async {
        do {
            let email = try await connectGoogleCalendarUseCase.execute(presentingViewController: presentingViewController)
            self.isGoogleConnected = true
            self.googleUserEmail = email
            self.googleAuthError = nil
            await syncAllTasksToGoogleCalendar()
        } catch {
            self.isGoogleConnected = false
            self.googleUserEmail = nil
            let userMessage = error.localizedDescription.isEmpty ? "Failed to connect to Google Calendar. Please try again or check your connection." : error.localizedDescription
            self.googleAuthError = userMessage
        }
    }

    func disconnectGoogleCalendar() {
        disconnectGoogleCalendarUseCase.execute()
        isGoogleConnected = false
        googleUserEmail = nil
    }

    func syncAllTasksToGoogleCalendar() async {
        do {
            try await syncTasksToGoogleCalendarUseCase.execute(tasks: allTasks)
            self.syncStatus = "All tasks synced to Google Calendar!"
        } catch {
            let userMessage = error.localizedDescription.isEmpty ? "Sync failed. Please check your connection or re-authenticate." : error.localizedDescription
            self.syncStatus = userMessage
        }
    }

    private func restoreGoogleSignInIfNeeded() async {
        let email = await restoreGoogleSignInUseCase.execute()
        if let email = email {
            await MainActor.run {
                self.isGoogleConnected = true
                self.googleUserEmail = email
            }
        }
    }
}
