// SessionManager.swift
// BluePond Wellness

import Foundation

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Key {
        static let accessToken      = "bp_access_token"
        static let refreshToken     = "bp_refresh_token"
        static let userId           = "bp_user_id"
        static let participantId    = "bp_participant_id"
        static let participantRole  = "bp_participant_role"
        static let participantEmail = "bp_participant_email"
        static let displayName      = "bp_display_name"
        static let isLoggedIn       = "bp_is_logged_in"
        static let hasSeenOnboarding = "bp_onboarding_seen"
    }

    // MARK: - Stored Properties

    var accessToken: String? {
        get { defaults.string(forKey: Key.accessToken) }
        set { defaults.set(newValue, forKey: Key.accessToken) }
    }

    var refreshToken: String? {
        get { defaults.string(forKey: Key.refreshToken) }
        set { defaults.set(newValue, forKey: Key.refreshToken) }
    }

    var userId: String? {
        get { defaults.string(forKey: Key.userId) }
        set { defaults.set(newValue, forKey: Key.userId) }
    }

    var participantId: String? {
        get { defaults.string(forKey: Key.participantId) }
        set { defaults.set(newValue, forKey: Key.participantId) }
    }

    var participantRole: String? {
        get { defaults.string(forKey: Key.participantRole) }
        set { defaults.set(newValue, forKey: Key.participantRole) }
    }

    var participantEmail: String? {
        get { defaults.string(forKey: Key.participantEmail) }
        set { defaults.set(newValue, forKey: Key.participantEmail) }
    }

    var displayName: String? {
        get { defaults.string(forKey: Key.displayName) }
        set { defaults.set(newValue, forKey: Key.displayName) }
    }

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Key.isLoggedIn) }
        set { defaults.set(newValue, forKey: Key.isLoggedIn) }
    }

    /// `true` once the user has completed or skipped the 3-page onboarding flow.
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }

    /// Sets the onboarding-seen flag. Called by OnboardingViewController on completion or skip.
    func setOnboardingSeen(_ seen: Bool) {
        hasSeenOnboarding = seen
    }

    // MARK: - Methods

    func saveSession(auth: AuthResponse, participant: Participant) {
        accessToken         = auth.accessToken
        refreshToken        = auth.refreshToken
        userId              = auth.user.id
        participantId       = participant.id
        participantRole     = participant.role
        participantEmail    = participant.email
        displayName         = participant.displayName
        isLoggedIn          = true
        SupabaseService.shared.accessToken = auth.accessToken
    }

    func clearSession() {
        let keys = [
            Key.accessToken, Key.refreshToken, Key.userId,
            Key.participantId, Key.participantRole,
            Key.participantEmail, Key.displayName
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        isLoggedIn = false
        SupabaseService.shared.accessToken = nil
    }

    func getCurrentRole() -> String {
        return participantRole ?? "Employee"
    }

    func isAdmin() -> Bool {
        let role = getCurrentRole()
        let adminRoles: Set<String> = [
            "Wellness Coordinator",
            "Org Admin",
            "Super Admin"
        ]
        return adminRoles.contains(role)
    }
}
