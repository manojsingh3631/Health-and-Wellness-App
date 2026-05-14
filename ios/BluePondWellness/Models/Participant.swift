// Participant.swift
// BluePond Wellness

import Foundation

struct Participant: Codable {
    var id: String?
    var authUserId: String?
    var displayName: String
    var employeeId: String
    var email: String
    var department: String?
    var team: String?
    var heightCm: Double?
    var weightKg: Double?
    var bmi: Double?
    var bloodGroup: String?
    var shiftType: String
    var shiftStartTime: String?
    var shiftEndTime: String?
    var reminderWindow1: String?
    var reminderWindow2: String?
    var reminderFrequency: String
    var role: String
    var status: String
    var consentAccepted: Bool
    var consentDate: String?
    var onboardingComplete: Bool
    var currentStreak: Int
    var longestStreak: Int
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case authUserId         = "auth_user_id"
        case displayName        = "display_name"
        case employeeId         = "employee_id"
        case email
        case department
        case team
        case heightCm           = "height_cm"
        case weightKg           = "weight_kg"
        case bmi
        case bloodGroup         = "blood_group"
        case shiftType          = "shift_type"
        case shiftStartTime     = "shift_start_time"
        case shiftEndTime       = "shift_end_time"
        case reminderWindow1    = "reminder_window_1"
        case reminderWindow2    = "reminder_window_2"
        case reminderFrequency  = "reminder_frequency"
        case role
        case status
        case consentAccepted    = "consent_accepted"
        case consentDate        = "consent_date"
        case onboardingComplete = "onboarding_complete"
        case currentStreak      = "current_streak"
        case longestStreak      = "longest_streak"
        case createdAt          = "created_at"
        case updatedAt          = "updated_at"
    }

    // MARK: - Computed

    var bmiCategory: String {
        guard let bmiValue = bmi else { return "Unknown" }
        switch bmiValue {
        case ..<18.5:  return "Underweight"
        case 18.5..<25: return "Healthy"
        case 25..<30:  return "Overweight"
        default:       return "Obese"
        }
    }

    var displayInitials: String {
        let parts = displayName.split(separator: " ").map(String.init)
        let first = parts.first?.first.map(String.init) ?? ""
        let last  = parts.count > 1 ? (parts.last?.first.map(String.init) ?? "") : ""
        return (first + last).uppercased()
    }
}
