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
    private let updateTaskUseCase: UpdateTaskUseCase?
    private var editingTask: TaskModel?
    var isEditing: Bool { editingTask != nil }

    init(addTaskUseCase: AddTaskUseCase,
         getCategoriesUseCase: GetCategoriesUseCase,
         syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase,
         restoreGoogleSignInUseCase: RestoreGoogleSignInUseCase,
         updateTaskUseCase: UpdateTaskUseCase,
         editingTask: TaskModel? = nil) {
        self.addTaskUseCase = addTaskUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        self.syncTaskToGoogleCalendarUseCase = syncTaskToGoogleCalendarUseCase
        self.restoreGoogleSignInUseCase = restoreGoogleSignInUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.editingTask = editingTask
        if let task = editingTask {
            self.title = task.title
            self.date = task.date
            self.start = task.startTime
            self.end = task.endTime
            self.notes = task.notes
            self.repeatRule = task.repeatRule
            self.selected = task.category
        }
        Task { categories = try await getCategoriesUseCase.execute() }
    }
    
    func addCat(_ n:String) {
        selected = n
        if !categories.contains(n) { categories.append(n) }
    }
    
    func save() {
        print("[TaskFormViewModel] save() called")
        guard !title.isEmpty else { error="Title required"; print("[TaskFormViewModel] Title required"); return }
        let minDuration: TimeInterval = 10 * 60 // 10 minutes in seconds
        if end.timeIntervalSince(start) < minDuration {
            error = "End time must be at least 10 minutes after start time."
            print("[TaskFormViewModel] End time must be at least 10 minutes after start time.")
            return
        }
        Task{
            do {
                let task = TaskModel(
                    id: editingTask?.id ?? UUID(),
                    title: title,
                    date: date,
                    startTime: start,
                    endTime: end,
                    notes: notes,
                    category: selected,
                    repeatRule: repeatRule,
                    status: editingTask?.status ?? .created,
                    eventId: editingTask?.eventId,
                    eventIds: editingTask?.eventIds
                )
                print("[TaskFormViewModel] TaskModel created: \(task)")
                if isEditing, let updateTaskUseCase = updateTaskUseCase {
                    print("[TaskFormViewModel] Editing existing task, updating...")
                    try await updateTaskUseCase.execute(task)
                } else {
                    print("[TaskFormViewModel] Adding new task...")
                    try await addTaskUseCase.execute(task)
                    scheduleNotification(for: task)
                    print("[TaskFormViewModel] Notification scheduled for task: \(task.title)")
                    if let syncUseCase = syncTaskToGoogleCalendarUseCase, let updateTaskUseCase = updateTaskUseCase {
                        print("[TaskFormViewModel] Attempting to sync task to Google Calendar: \(task.title)")
                        do {
                            try await restoreGoogleSignInUseCase.execute()
                            print("[TaskFormViewModel] Google sign-in restored")
                            let eventIdMap = try await syncUseCase.execute(task: task)
                            print("[TaskFormViewModel] eventIdMap from sync: \(eventIdMap)")
                            if repeatRule == .none {
                                // Single event
                                if let eventId = eventIdMap[task.id] {
                                    print("[TaskFormViewModel] Updating task with eventId: \(eventId)")
                                    let updatedTask = TaskModel(
                                        id: task.id,
                                        title: task.title,
                                        date: task.date,
                                        startTime: task.startTime,
                                        endTime: task.endTime,
                                        notes: task.notes,
                                        category: task.category,
                                        repeatRule: task.repeatRule,
                                        status: task.status,
                                        eventId: eventId,
                                        eventIds: nil
                                    )
                                    try await updateTaskUseCase.execute(updatedTask)
                                    print("[TaskFormViewModel] Task updated with eventId")
                                } else {
                                    print("[TaskFormViewModel] No eventId found in eventIdMap for task.id: \(task.id)")
                                }
                            } else {
                                // Repeated events
                                let eventIds = Array(eventIdMap.values)
                                print("[TaskFormViewModel] Updating task with eventIds: \(eventIds)")
                                if !eventIds.isEmpty {
                                    let updatedTask = TaskModel(
                                        id: task.id,
                                        title: task.title,
                                        date: task.date,
                                        startTime: task.startTime,
                                        endTime: task.endTime,
                                        notes: task.notes,
                                        category: task.category,
                                        repeatRule: task.repeatRule,
                                        status: task.status,
                                        eventId: nil,
                                        eventIds: eventIds
                                    )
                                    try await updateTaskUseCase.execute(updatedTask)
                                    print("[TaskFormViewModel] Task updated with eventIds")
                                } else {
                                    print("[TaskFormViewModel] No eventIds found in eventIdMap for repeated task")
                                }
                            }
                            print("[TaskFormViewModel] Successfully synced task to Google Calendar: \(task.title)")
                        } catch {
                            let syncErrorMsg = error.localizedDescription.isEmpty ? "Failed to sync task to Google Calendar. Please check your connection or re-authenticate." : error.localizedDescription
                            self.error = syncErrorMsg
                            print("[TaskFormViewModel] Failed to sync task to Google Calendar: \(syncErrorMsg)")
                        }
                    } else {
                        print("[TaskFormViewModel] Skipping Google Calendar sync (syncUseCase or updateTaskUseCase is nil)")
                    }
                }
                saved = true
                self.error = nil
                print("[TaskFormViewModel] Task save complete")
            } catch {
                self.error = error.localizedDescription.isEmpty ? "Failed to save task. Please try again." : error.localizedDescription
                print("[TaskFormViewModel] Error in save(): \(self.error ?? "Unknown error")")
            }
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
