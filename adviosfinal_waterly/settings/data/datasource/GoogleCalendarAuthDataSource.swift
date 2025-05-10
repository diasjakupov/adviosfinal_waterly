import Foundation
import GoogleSignIn
import GoogleSignInSwift
import UIKit

// MARK: - Authentication
extension GoogleCalendarRemoteDataSource {
    /// Signs in the user with Google and requests calendar access.
    func signIn(presentingViewController: UIViewController) async throws -> GIDGoogleUser {
        print("[GoogleCalendarRemoteDataSource] signIn called")
        let additionalScopes = ["https://www.googleapis.com/auth/calendar"]
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: additionalScopes
            ) { user, error in
                if let error = error {
                    print("[GoogleCalendarRemoteDataSource] signIn error: \(error)")
                    continuation.resume(throwing: error)
                } else if let user = user {
                    print("[GoogleCalendarRemoteDataSource] signIn success: \(user.user.profile?.email ?? "<no email>")")
                    continuation.resume(returning: user.user)
                }
            }
        }
    }

    /// Restores previous Google sign-in session if available.
    func restorePreviousSignIn() async -> GIDGoogleUser? {
        print("[GoogleCalendarRemoteDataSource] restorePreviousSignIn called")
        return await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let user = user {
                    print("[GoogleCalendarRemoteDataSource] restorePreviousSignIn success: \(user.profile?.email ?? "<no email>")")
                    continuation.resume(returning: user)
                } else {
                    if let error = error {
                        print("[GoogleCalendarRemoteDataSource] restorePreviousSignIn error: \(error)")
                    }
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Returns the current signed-in user's email, if available.
    func currentUserEmail() -> String? {
        GIDSignIn.sharedInstance.currentUser?.profile?.email
    }

    /// Signs out the current user.
    func signOut() {
        print("[GoogleCalendarRemoteDataSource] signOut called")
        GIDSignIn.sharedInstance.signOut()
    }

    /// Returns true if a user is currently signed in.
    func isSignedIn() -> Bool {
        let signedIn = GIDSignIn.sharedInstance.currentUser != nil
        print("[GoogleCalendarRemoteDataSource] isSignedIn: \(signedIn)")
        return signedIn
    }
} 