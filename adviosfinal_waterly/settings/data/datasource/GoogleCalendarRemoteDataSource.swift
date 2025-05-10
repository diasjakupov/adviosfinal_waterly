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

    func signIn(presentingViewController: UIViewController) async throws -> GIDGoogleUser {
        let additionalScopes = ["https://www.googleapis.com/auth/calendar"]
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: additionalScopes
            ) { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = user {
                    continuation.resume(returning: user.user)
                }
            }
        }
    }

    func restorePreviousSignIn() async -> GIDGoogleUser? {
        await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let user = user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func currentUserEmail() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.profile?.email
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    func isSignedIn() -> Bool {
        GIDSignIn.sharedInstance.currentUser != nil
    }

    func addTasksToCalendar(tasks: [TaskModel]) async throws {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("[GoogleCalendarRemoteDataSource] No Google user signed in. Cannot sync tasks.")
            throw NSError(domain: "No Google user", code: 0)
        }
        let accessToken = user.accessToken.tokenString
        let calendarId = "primary"
        let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/\(calendarId)/events")
        
        print("[GoogleCalendarRemoteDataSource] Syncing \(tasks.count) task(s) to Google Calendar...")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                    if let bodyData = try? JSONSerialization.data(withJSONObject: event), let bodyString = String(data: bodyData, encoding: .utf8) {
                        print("[GoogleCalendarRemoteDataSource] Event data: \(bodyString)")
                    }
                    let bodyData = try? JSONSerialization.data(withJSONObject: event)
                    request.httpBody = bodyData
                    do {
                        let (data, response) = try await URLSession.shared.data(for: request)
                        if let httpResponse = response as? HTTPURLResponse {
                            print("[GoogleCalendarRemoteDataSource] Response status: \(httpResponse.statusCode)")
                            if !(200...299).contains(httpResponse.statusCode) {
                                let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                                print("[GoogleCalendarRemoteDataSource] Error response body: \(responseString)")
                                throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
                            }
                        }
                    } catch {
                        print("[GoogleCalendarRemoteDataSource] Network or serialization error: \(error)")
                        throw error
                    }
                }
            }
            try await group.waitForAll()
        }
    }
} 
