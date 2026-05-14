// LeaderboardEntry.swift
// BluePond Wellness

import Foundation

struct LeaderboardEntry: Codable {
    var id: String
    var challengeId: String
    var leaderboardType: String
    var periodLabel: String
    var participantId: String
    var displayName: String
    var department: String?
    var teamName: String?
    var totalPoints: Double
    var rank: Int
    var isTied: Bool
    var generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case challengeId        = "challenge_id"
        case leaderboardType    = "leaderboard_type"
        case periodLabel        = "period_label"
        case participantId      = "participant_id"
        case displayName        = "display_name"
        case department
        case teamName           = "team_name"
        case totalPoints        = "total_points"
        case rank
        case isTied             = "is_tied"
        case generatedAt        = "generated_at"
    }
}
