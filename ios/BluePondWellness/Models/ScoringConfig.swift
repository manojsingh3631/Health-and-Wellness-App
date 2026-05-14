// ScoringConfig.swift
// BluePond Wellness

import Foundation

struct ScoringConfig: Codable {
    var id: String
    var challengeId: String
    var activityType: String
    var pointsPerUnit: Double
    var unitDescription: String?
    var unitThreshold: Double
    var dailyMaxPoints: Double
    var bonusThreshold: Double?
    var bonusPoints: Double?
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case challengeId        = "challenge_id"
        case activityType       = "activity_type"
        case pointsPerUnit      = "points_per_unit"
        case unitDescription    = "unit_description"
        case unitThreshold      = "unit_threshold"
        case dailyMaxPoints     = "daily_max_points"
        case bonusThreshold     = "bonus_threshold"
        case bonusPoints        = "bonus_points"
        case isActive           = "is_active"
    }
}
