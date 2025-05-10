//
//  GoogleCalendarRemoteDataSource.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 09.05.2025.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import UIKit

final class GoogleCalendarRemoteDataSource {
    static let shared = GoogleCalendarRemoteDataSource()
    private init() {}
}

// MARK: - Event Creation
extension GoogleCalendarRemoteDataSource {
    /// Adds multiple tasks to Google Calendar and returns a mapping of task UUIDs to event IDs.
    func addTasksToCalendar(tasks: [TaskModel]) async throws -> [UUID: String] {
        print("[GoogleCalendarRemoteDataSource] addTasksToCalendar called with \(tasks.count) tasks")
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("[GoogleCalendarRemoteDataSource] No Google user signed in. Cannot sync tasks.")
            throw NSError(domain: "No Google user", code: 0)
        }
        let accessToken = user.accessToken.tokenString
        let url = urlForEvents()
        print("[GoogleCalendarRemoteDataSource] Syncing \(tasks.count) task(s) to Google Calendar...")
        var eventIdMap: [UUID: String] = [:]
        try await withThrowingTaskGroup(of: (UUID, String?).self) { group in
            for task in tasks {
                group.addTask {
                    let request = self.makeEventRequest(url: url, method: "POST", accessToken: accessToken, task: task)
                    return try await self.performEventRequest(request, taskId: task.id)
                }
            }
            for try await (taskId, eventId) in group {
                if let eventId = eventId {
                    eventIdMap[taskId] = eventId
                }
            }
        }
        return eventIdMap
    }
}

// MARK: - Event Update
extension GoogleCalendarRemoteDataSource {
    /// Updates a task in Google Calendar using its eventId or eventIds.
    func updateTask(_ task: TaskModel) async throws {
        print("[GoogleCalendarRemoteDataSource] updateTask called for task id: \(task.id), eventId: \(task.eventId ?? "nil"), eventIds: \(task.eventIds ?? [])")
        
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("[GoogleCalendarRemoteDataSource] No Google user signed in. Cannot update task.")
            throw NSError(domain: "No Google user", code: 0)
        }
        let accessToken = user.accessToken.tokenString
        let event = eventDictionary(for: task)
        if let eventIds = task.eventIds, !eventIds.isEmpty {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for eventId in eventIds {
                    group.addTask {
                        let url = self.url(forEventId: eventId)
                        let request = self.makeEventRequest(url: url, method: "PUT", accessToken: accessToken, event: event)
                        try await self.performUpdateOrDeleteRequest(request, eventId: eventId, operation: "updateTask (repeated)")
                    }
                }
                try await group.waitForAll()
            }
        } else if let eventId = task.eventId {
            let url = url(forEventId: eventId)
            let request = makeEventRequest(url: url, method: "PUT", accessToken: accessToken, event: event)
            try await performUpdateOrDeleteRequest(request, eventId: eventId, operation: "updateTask")
        } else {
            print("[GoogleCalendarRemoteDataSource] No eventId or eventIds for task. Cannot update.")
            throw NSError(domain: "No eventId or eventIds for task", code: 0)
        }
    }
}

// MARK: - Event Deletion
extension GoogleCalendarRemoteDataSource {
    /// Deletes a task or all instances of a repeated task from Google Calendar.
    func deleteTask(_ task: TaskModel) async throws {
        print("[GoogleCalendarRemoteDataSource] deleteTask called for task id: \(task.id), eventId: \(task.eventId ?? "nil")")
        
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("[GoogleCalendarRemoteDataSource] No Google user signed in. Cannot delete task.")
            throw NSError(domain: "No Google user", code: 0)
        }
        
        let accessToken = user.accessToken.tokenString
        if task.repeatRule == .none {
            guard let eventId = task.eventId else {
                print("[GoogleCalendarRemoteDataSource] No eventId for task. Cannot delete.")
                throw NSError(domain: "No eventId for task", code: 0)
            }
            let url = url(forEventId: eventId)
            let request = makeRequest(url: url, method: "DELETE", accessToken: accessToken)
            try await performUpdateOrDeleteRequest(request, eventId: eventId, operation: "deleteTask")
        } else {
            guard let eventIds = task.eventIds else {
                print("[GoogleCalendarRemoteDataSource] No eventIds for repeated task. Cannot delete.")
                throw NSError(domain: "No eventIds for repeated task", code: 0)
            }
            try await withThrowingTaskGroup(of: Void.self) { group in
                for eventId in eventIds {
                    group.addTask {
                        let url = self.url(forEventId: eventId)
                        let request = self.makeRequest(url: url, method: "DELETE", accessToken: accessToken)
                        try await self.performUpdateOrDeleteRequest(request, eventId: eventId, operation: "deleteTask (repeated)")
                    }
                }
                try await group.waitForAll()
            }
        }
    }
}

// MARK: - Helpers
private extension GoogleCalendarRemoteDataSource {
    /// Constructs the event dictionary for Google Calendar API from a TaskModel.
    func eventDictionary(for task: TaskModel) -> [String: Any] {
        let calendar = Calendar.current
        let startDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: task.startTime),
            minute: calendar.component(.minute, from: task.startTime),
            second: calendar.component(.second, from: task.startTime),
            of: task.date
        ) ?? task.startTime
        let endDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: task.endTime),
            minute: calendar.component(.minute, from: task.endTime),
            second: calendar.component(.second, from: task.endTime),
            of: task.date
        ) ?? task.endTime
        var event: [String: Any] = [
            "summary": task.title,
            "description": task.notes,
            "start": [
                "dateTime": ISO8601DateFormatter().string(from: startDateTime),
                "timeZone": TimeZone.current.identifier
            ],
            "end": [
                "dateTime": ISO8601DateFormatter().string(from: endDateTime),
                "timeZone": TimeZone.current.identifier
            ]
        ]
        switch task.repeatRule {
        case .daily:
            event["recurrence"] = ["RRULE:FREQ=DAILY"]
        case .weekly:
            event["recurrence"] = ["RRULE:FREQ=WEEKLY"]
        default:
            break
        }
        return event
    }

    /// Returns the URL for Google Calendar events endpoint.
    func urlForEvents() -> URL {
        URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!
    }

    /// Returns the URL for a specific Google Calendar event by eventId.
    func url(forEventId eventId: String) -> URL {
        URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events/\(eventId)")!
    }

    /// Creates a URLRequest with the given method and access token.
    func makeRequest(url: URL, method: String, accessToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    /// Creates a URLRequest for event creation or update with the given event dictionary.
    func makeEventRequest(url: URL, method: String, accessToken: String, task: TaskModel) -> URLRequest {
        makeEventRequest(url: url, method: method, accessToken: accessToken, event: eventDictionary(for: task))
    }
    func makeEventRequest(url: URL, method: String, accessToken: String, event: [String: Any]) -> URLRequest {
        var request = makeRequest(url: url, method: method, accessToken: accessToken)
        request.httpBody = try? JSONSerialization.data(withJSONObject: event)
        return request
    }

    /// Performs a network request for event creation and returns the eventId.
    func performEventRequest(_ request: URLRequest, taskId: UUID) async throws -> (UUID, String?) {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[GoogleCalendarRemoteDataSource] Response status: \(httpResponse.statusCode)")
            if (200...299).contains(httpResponse.statusCode) {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let eventId = json["id"] as? String {
                    print("[GoogleCalendarRemoteDataSource] Created eventId: \(eventId)")
                    return (taskId, eventId)
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                print("[GoogleCalendarRemoteDataSource] Error response body: \(responseString)")
                throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
            }
        }
        return (taskId, nil)
    }

    /// Performs a network request for event update or deletion.
    func performUpdateOrDeleteRequest(_ request: URLRequest, eventId: String, operation: String) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("[GoogleCalendarRemoteDataSource] \(operation) response status: \(httpResponse.statusCode) for eventId: \(eventId)")
            if !(200...299).contains(httpResponse.statusCode) {
                let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                print("[GoogleCalendarRemoteDataSource] \(operation) error response body: \(responseString)")
                throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
            }
        }
    }
} 
