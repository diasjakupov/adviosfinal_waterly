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

// MARK: - Task Operations
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
                    var request = self.makeRequest(url: url, method: "POST", accessToken: accessToken)
                    let event = self.eventDictionary(for: task)
                    if let bodyData = try? JSONSerialization.data(withJSONObject: event), let bodyString = String(data: bodyData, encoding: .utf8) {
                        print("[GoogleCalendarRemoteDataSource] Event data: \(bodyString)")
                    }
                    request.httpBody = try? JSONSerialization.data(withJSONObject: event)
                    do {
                        let (data, response) = try await URLSession.shared.data(for: request)
                        if let httpResponse = response as? HTTPURLResponse {
                            print("[GoogleCalendarRemoteDataSource] Response status: \(httpResponse.statusCode)")
                            if (200...299).contains(httpResponse.statusCode) {
                                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let eventId = json["id"] as? String {
                                    print("[GoogleCalendarRemoteDataSource] Created eventId: \(eventId)")
                                    return (task.id, eventId)
                                }
                            } else {
                                let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                                print("[GoogleCalendarRemoteDataSource] Error response body: \(responseString)")
                                throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
                            }
                        }
                        return (task.id, nil)
                    } catch {
                        print("[GoogleCalendarRemoteDataSource] Network or serialization error: \(error)")
                        throw error
                    }
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
            // Repeated task: update all events
            try await withThrowingTaskGroup(of: Void.self) { group in
                for eventId in eventIds {
                    group.addTask {
                        let url = self.url(forEventId: eventId)
                        var request = self.makeRequest(url: url, method: "PUT", accessToken: accessToken)
                        request.httpBody = try? JSONSerialization.data(withJSONObject: event)
                        do {
                            let (data, response) = try await URLSession.shared.data(for: request)
                            if let httpResponse = response as? HTTPURLResponse {
                                print("[GoogleCalendarRemoteDataSource] updateTask (repeated) response status: \(httpResponse.statusCode) for eventId: \(eventId)")
                                if !(200...299).contains(httpResponse.statusCode) {
                                    let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                                    print("[GoogleCalendarRemoteDataSource] updateTask (repeated) error response body: \(responseString)")
                                    throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
                                }
                            }
                        } catch {
                            print("[GoogleCalendarRemoteDataSource] updateTask (repeated) network or serialization error: \(error)")
                            throw error
                        }
                    }
                }
                try await group.waitForAll()
            }
        } else if let eventId = task.eventId {
            // Single event
            let url = url(forEventId: eventId)
            var request = makeRequest(url: url, method: "PUT", accessToken: accessToken)
            request.httpBody = try? JSONSerialization.data(withJSONObject: event)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    print("[GoogleCalendarRemoteDataSource] updateTask response status: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                        print("[GoogleCalendarRemoteDataSource] updateTask error response body: \(responseString)")
                        throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
                    }
                }
            } catch {
                print("[GoogleCalendarRemoteDataSource] updateTask network or serialization error: \(error)")
                throw error
            }
        } else {
            print("[GoogleCalendarRemoteDataSource] No eventId or eventIds for task. Cannot update.")
            throw NSError(domain: "No eventId or eventIds for task", code: 0)
        }
    }

    /// Deletes a task or all instances of a repeated task from Google Calendar.
    func deleteTask(_ task: TaskModel) async throws {
        print("[GoogleCalendarRemoteDataSource] deleteTask called for task id: \(task.id), eventId: \(task.eventId ?? "nil")")
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("[GoogleCalendarRemoteDataSource] No Google user signed in. Cannot delete task.")
            throw NSError(domain: "No Google user", code: 0)
        }
        let accessToken = user.accessToken.tokenString
        let calendarId = "primary"
        if task.repeatRule == .none {
            guard let eventId = task.eventId else {
                print("[GoogleCalendarRemoteDataSource] No eventId for task. Cannot delete.")
                throw NSError(domain: "No eventId for task", code: 0)
            }
            let url = url(forEventId: eventId)
            var request = makeRequest(url: url, method: "DELETE", accessToken: accessToken)
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    print("[GoogleCalendarRemoteDataSource] deleteTask response status: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("[GoogleCalendarRemoteDataSource] deleteTask failed with status: \(httpResponse.statusCode)")
                        throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode)
                    }
                }
            } catch {
                print("[GoogleCalendarRemoteDataSource] deleteTask network or serialization error: \(error)")
                throw error
            }
        } else {
            guard let eventIds = task.eventIds else {
                print("[GoogleCalendarRemoteDataSource] No eventIds for repeated task. Cannot delete.")
                throw NSError(domain: "No eventIds for repeated task", code: 0)
            }
            try await withThrowingTaskGroup(of: Void.self) { group in
                for eventId in eventIds {
                    group.addTask {
                        let url = self.url(forEventId: eventId)
                        var request = self.makeRequest(url: url, method: "DELETE", accessToken: accessToken)
                        do {
                            let (_, response) = try await URLSession.shared.data(for: request)
                            if let httpResponse = response as? HTTPURLResponse {
                                print("[GoogleCalendarRemoteDataSource] deleteTask (repeated) response status: \(httpResponse.statusCode)")
                                if !(200...299).contains(httpResponse.statusCode) {
                                    print("[GoogleCalendarRemoteDataSource] deleteTask (repeated) failed with status: \(httpResponse.statusCode)")
                                    throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode)
                                }
                            }
                        } catch {
                            print("[GoogleCalendarRemoteDataSource] deleteTask (repeated) network or serialization error: \(error)")
                            throw error
                        }
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
} 
