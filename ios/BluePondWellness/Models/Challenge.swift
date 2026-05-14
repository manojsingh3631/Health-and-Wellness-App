// Challenge.swift
// BluePond Wellness

import Foundation

struct Challenge: Codable {
    var id: String
    var title: String
    var description: String?
    var startDate: String
    var endDate: String
    var submissionDeadlineTime: String
    var allowOneEdit: Bool
    var isActive: Bool
    var includeSteps: Bool
    var includeWater: Bool
    var includeYoga: Bool
    var includeWorkout: Bool
    var includeSugarFree: Bool
    var leaderboardDisplayField: String
    var showDepartment: Bool
    var teamLeaderboardEnabled: Bool
    var tieHandlingRule: String
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case startDate              = "start_date"
        case endDate                = "end_date"
        case submissionDeadlineTime = "submission_deadline_time"
        case allowOneEdit           = "allow_one_edit"
        case isActive               = "is_active"
        case includeSteps           = "include_steps"
        case includeWater           = "include_water"
        case includeYoga            = "include_yoga"
        case includeWorkout         = "include_workout"
        case includeSugarFree       = "include_sugar_free"
        case leaderboardDisplayField = "leaderboard_display_field"
        case showDepartment         = "show_department"
        case teamLeaderboardEnabled = "team_leaderboard_enabled"
        case tieHandlingRule        = "tie_handling_rule"
        case createdAt              = "created_at"
    }

    // MARK: - Computed

    var daysRemaining: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let end = formatter.date(from: endDate) else { return 0 }
        let now = Calendar.current.startOfDay(for: Date())
        let endDay = Calendar.current.startOfDay(for: end)
        let components = Calendar.current.dateComponents([.day], from: now, to: endDay)
        return max(0, components.day ?? 0)
    }
}
