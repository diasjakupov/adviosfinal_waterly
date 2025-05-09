//
//  TaskFormViewModel.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 06.05.2025.
//


import SwiftUI
import Combine
import UserNotifications

@MainActor
final class TaskFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var date  = Date()
    @Published var start = Date()
    @Published var end   = Date()
    @Published var notes = ""
    @Published var repeatRule: RepeatRule = .none
    
    @Published var categories: [String] = []
    @Published var selected: String? = nil
    @Published var saved = false
    @Published var error: String?
    
    private let addTaskUseCase: AddTaskUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase
    private let syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase?
    private let restoreGoogleSignInUseCase: RestoreGoogleSignInUseCase

        
    init(addTaskUseCase: AddTaskUseCase, getCategoriesUseCase: GetCategoriesUseCase, syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase? = nil,
         restoreGoogleSignInUseCase: RestoreGoogleSignInUseCase
) {
        self.addTaskUseCase = addTaskUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        self.syncTaskToGoogleCalendarUseCase = syncTaskToGoogleCalendarUseCase
        self.restoreGoogleSignInUseCase = restoreGoogleSignInUseCase
        Task { categories = try await getCategoriesUseCase.execute() }
    }
    
    func addCat(_ n:String) {
        selected = n
        if !categories.contains(n) { categories.append(n) }
    }
    
    func save() {
        guard !title.isEmpty else { error="Title required"; return }
        let minDuration: TimeInterval = 10 * 60 // 10 minutes in seconds
        if end.timeIntervalSince(start) < minDuration {
            error = "End time must be at least 10 minutes after start time."
            return
        }
        Task{
            do {
                let task = TaskModel(title:title,date:date,startTime:start,endTime:end,
                              notes:notes,category:selected,repeatRule:repeatRule)
                try await addTaskUseCase.execute(task)
                scheduleNotification(for: task)
                if let syncUseCase = syncTaskToGoogleCalendarUseCase {
                    print("[TaskFormViewModel] Attempting to sync task to Google Calendar: \(task.title)")
                    do {
                        try await restoreGoogleSignInUseCase.execute()
                        try await syncUseCase.execute(task: task)
                        print("[TaskFormViewModel] Successfully synced task to Google Calendar: \(task.title)")
                    } catch {
                        print("[TaskFormViewModel] Failed to sync task to Google Calendar: \(error.localizedDescription)")
                    }
                }
                saved = true
            } catch { self.error = error.localizedDescription }
        }
    }

    private func scheduleNotification(for task: TaskModel) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.notes
        content.sound = .default
        let calendar = Calendar.current
        let triggerDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: task.startTime),
            minute: calendar.component(.minute, from: task.startTime),
            second: calendar.component(.second, from: task.startTime),
            of: task.date
        ) ?? task.startTime
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
