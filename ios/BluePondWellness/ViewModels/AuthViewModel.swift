// AuthViewModel.swift
// BluePond Wellness

import Foundation
import Combine

final class AuthViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = SessionManager.shared.isLoggedIn

    // MARK: - Login

    func login(email: String, password: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate inputs
        guard isValidEmail(trimmedEmail) else {
            await updateError("Please enter a valid email address.")
            return
        }
        guard trimmedPassword.count >= 6 else {
            await updateError("Password must be at least 6 characters.")
            return
        }

        await setLoading(true)
        await updateError(nil)

        do {
            let authResponse = try await SupabaseService.shared.login(
                email: trimmedEmail,
                password: trimmedPassword
            )
            let participant = try await SupabaseService.shared.fetchParticipant(
                authUserId: authResponse.user.id
            )
            SessionManager.shared.saveSession(auth: authResponse, participant: participant)
            await setLoading(false)
            await MainActor.run {
                self.isLoggedIn = true
            }
        } catch let error as SupabaseError {
            await setLoading(false)
            await updateError(error.errorDescription ?? "Login failed.")
        } catch {
            await setLoading(false)
            await updateError(error.localizedDescription)
        }
    }

    // MARK: - Logout

    func logout() async {
        await setLoading(true)
        do {
            try await SupabaseService.shared.logout()
        } catch {
            // Proceed with local session clear even if remote logout fails
        }
        SessionManager.shared.clearSession()
        await setLoading(false)
        await MainActor.run {
            self.isLoggedIn = false
        }
    }

    // MARK: - Private Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }

    @MainActor
    private func setLoading(_ loading: Bool) {
        self.isLoading = loading
    }

    @MainActor
    private func updateError(_ message: String?) {
        self.errorMessage = message
    }
}
