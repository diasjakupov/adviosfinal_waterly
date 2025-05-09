import Foundation
import GoogleSignIn
import GoogleSignInSwift
import UIKit

final class GoogleCalendarRemoteDataSource {
    static let shared = GoogleCalendarRemoteDataSource()
    private init() {}

    func signIn(presentingViewController: UIViewController) async throws -> GIDGoogleUser {
        let config = GIDConfiguration(clientID: "<YOUR_CLIENT_ID>")
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
            throw NSError(domain: "No Google user", code: 0)
        }
        let accessToken = user.accessToken.tokenString
        let calendarId = "primary"
        let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/\(calendarId)/events")!
        for task in tasks {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let event: [String: Any] = [
                "summary": task.title,
                "description": task.notes,
                "start": [
                    "dateTime": ISO8601DateFormatter().string(from: task.startTime),
                    "timeZone": TimeZone.current.identifier
                ],
                "end": [
                    "dateTime": ISO8601DateFormatter().string(from: task.endTime),
                    "timeZone": TimeZone.current.identifier
                ]
            ]
            let bodyData = try? JSONSerialization.data(withJSONObject: event)
            request.httpBody = bodyData
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    let responseString = String(data: data, encoding: .utf8) ?? "<no response body>"
                    throw NSError(domain: "Google Calendar API error", code: httpResponse.statusCode, userInfo: ["response": responseString])
                }
            } catch {
                throw error
            }
        }
    }
} 
