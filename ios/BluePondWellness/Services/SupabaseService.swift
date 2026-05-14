// SupabaseService.swift
// BluePond Wellness
// Singleton URLSession-based Supabase REST client

import Foundation

// MARK: - Error Types

enum SupabaseError: Error, LocalizedError {
    case authError(String)
    case networkError(Error)
    case serverError(Int, String)
    case decodingError(Error)
    case invalidURL
    case noAccessToken

    var errorDescription: String? {
        switch self {
        case .authError(let msg):       return "Authentication error: \(msg)"
        case .networkError(let err):    return "Network error: \(err.localizedDescription)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg)"
        case .decodingError(let err):   return "Decoding error: \(err.localizedDescription)"
        case .invalidURL:               return "Invalid URL"
        case .noAccessToken:            return "No access token available"
        }
    }
}

// MARK: - SupabaseService

final class SupabaseService {

    static let shared = SupabaseService()

    private let session: URLSession
    private let supabaseURL: String
    private let anonKey: String
    var accessToken: String?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
            let url = dict["SUPABASE_URL"] as? String,
            let key = dict["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Config.plist missing SUPABASE_URL or SUPABASE_ANON_KEY")
        }

        self.supabaseURL = url
        self.anonKey = key
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws -> AuthResponse {
        struct LoginBody: Encodable {
            let email: String
            let password: String
        }
        let body = LoginBody(email: email, password: password)
        let response: AuthResponse = try await request(
            path: "/auth/v1/token?grant_type=password",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        self.accessToken = response.accessToken
        return response
    }

    func logout() async throws {
        let _: EmptyResponse = try await request(
            path: "/auth/v1/logout",
            method: "POST",
            body: Optional<String>.none,
            requiresAuth: true
        )
        self.accessToken = nil
    }

    // MARK: - Participant

    func fetchParticipant(authUserId: String) async throws -> Participant {
        let encoded = authUserId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? authUserId
        let participants: [Participant] = try await request(
            path: "/rest/v1/participants?auth_user_id=eq.\(encoded)&limit=1",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
        guard let participant = participants.first else {
            throw SupabaseError.serverError(404, "Participant not found")
        }
        return participant
    }

    func updateParticipant(_ participant: Participant) async throws {
        guard let pid = participant.id else {
            throw SupabaseError.serverError(400, "Participant id is nil")
        }
        let encoded = pid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? pid
        let _: [Participant] = try await request(
            path: "/rest/v1/participants?id=eq.\(encoded)",
            method: "PATCH",
            body: participant,
            requiresAuth: true
        )
    }

    // MARK: - Challenges

    func getActiveChallenges() async throws -> [Challenge] {
        return try await request(
            path: "/rest/v1/challenges?is_active=eq.true&order=start_date.desc",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    // MARK: - Scoring Config

    func getScoringConfig(challengeId: String) async throws -> [ScoringConfig] {
        let encoded = challengeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? challengeId
        return try await request(
            path: "/rest/v1/scoring_config?challenge_id=eq.\(encoded)&is_active=eq.true",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    // MARK: - Activity Logs

    func getActivityLogs(participantId: String, challengeId: String) async throws -> [ActivityLog] {
        let pEncoded = participantId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? participantId
        let cEncoded = challengeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? challengeId
        return try await request(
            path: "/rest/v1/activity_logs?participant_id=eq.\(pEncoded)&challenge_id=eq.\(cEncoded)&order=activity_date.desc",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    func submitActivityLog(_ log: ActivityLog) async throws -> ActivityLog {
        let logs: [ActivityLog] = try await request(
            path: "/rest/v1/activity_logs",
            method: "POST",
            body: log,
            requiresAuth: true
        )
        guard let created = logs.first else {
            throw SupabaseError.serverError(500, "No log returned after insert")
        }
        return created
    }

    func updateActivityLog(_ log: ActivityLog) async throws {
        guard let lid = log.id else {
            throw SupabaseError.serverError(400, "ActivityLog id is nil")
        }
        let encoded = lid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? lid
        let _: [ActivityLog] = try await request(
            path: "/rest/v1/activity_logs?id=eq.\(encoded)",
            method: "PATCH",
            body: log,
            requiresAuth: true
        )
    }

    // MARK: - Leaderboard

    func getLeaderboard(challengeId: String, type: String) async throws -> [LeaderboardEntry] {
        let cEncoded = challengeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? challengeId
        let tEncoded = type.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? type
        return try await request(
            path: "/rest/v1/leaderboard_entries?challenge_id=eq.\(cEncoded)&leaderboard_type=eq.\(tEncoded)&order=rank.asc",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    // MARK: - FAQs

    func getFaqs() async throws -> [FAQ] {
        return try await request(
            path: "/rest/v1/faqs?is_published=eq.true&order=display_order.asc",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    // MARK: - Reminders

    func getReminders(participantId: String) async throws -> [Reminder] {
        let encoded = participantId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? participantId
        return try await request(
            path: "/rest/v1/reminders?participant_id=eq.\(encoded)",
            method: "GET",
            body: Optional<String>.none,
            requiresAuth: true
        )
    }

    func updateReminder(_ reminder: Reminder) async throws {
        guard let rid = reminder.id else {
            throw SupabaseError.serverError(400, "Reminder id is nil")
        }
        let encoded = rid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? rid
        let _: [Reminder] = try await request(
            path: "/rest/v1/reminders?id=eq.\(encoded)",
            method: "PATCH",
            body: reminder,
            requiresAuth: true
        )
    }

    // MARK: - Private Request Helper

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: (some Encodable)?,
        requiresAuth: Bool
    ) async throws -> T {
        guard let url = URL(string: supabaseURL + path) else {
            throw SupabaseError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("return=representation", forHTTPHeaderField: "Prefer")

        if requiresAuth {
            guard let token = accessToken else {
                throw SupabaseError.noAccessToken
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw SupabaseError.decodingError(error)
            }
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw SupabaseError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            if statusCode == 401 {
                let message = String(data: data, encoding: .utf8) ?? "Unauthorized"
                throw SupabaseError.authError(message)
            }
            if statusCode < 200 || statusCode >= 300 {
                let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
                throw SupabaseError.serverError(statusCode, message)
            }
        }

        // Handle empty response (e.g. logout 204)
        if data.isEmpty, let emptyResult = EmptyResponse() as? T {
            return emptyResult
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SupabaseError.decodingError(error)
        }
    }
}

// MARK: - EmptyResponse helper

private struct EmptyResponse: Codable {}
