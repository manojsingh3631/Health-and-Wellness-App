// ActivityLog.swift
// BluePond Wellness

import Foundation

struct ActivityLog: Codable {
    var id: String?
    var participantId: String
    var challengeId: String
    var activityDate: String
    var stepsCount: Int
    var waterIntakeLiters: Double
    var yogaMinutes: Int
    var workoutMinutes: Int
    var noAddedSugarDay: Bool
    var pointsEarned: Double
    var editCount: Int
    var dataSource: String
    var status: String
    var isVoided: Bool
    var submittedAt: String?
    var lastModifiedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case participantId      = "participant_id"
        case challengeId        = "challenge_id"
        case activityDate       = "activity_date"
        case stepsCount         = "steps_count"
        case waterIntakeLiters  = "water_intake_liters"
        case yogaMinutes        = "yoga_minutes"
        case workoutMinutes     = "workout_minutes"
        case noAddedSugarDay    = "no_added_sugar_day"
        case pointsEarned       = "points_earned"
        case editCount          = "edit_count"
        case dataSource         = "data_source"
        case status
        case isVoided           = "is_voided"
        case submittedAt        = "submitted_at"
        case lastModifiedAt     = "last_modified_at"
    }

    // MARK: - Computed

    var canEdit: Bool {
        return editCount < 1 && !isVoided
    }
}
