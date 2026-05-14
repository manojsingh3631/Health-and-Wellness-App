// Reminder.swift
// BluePond Wellness

import Foundation

struct Reminder: Codable {
    var id: String?
    var participantId: String
    var reminderType: String
    var reminderTime: String
    var frequencyType: String
    var isEnabled: Bool
    var lastSentAt: String?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case participantId  = "participant_id"
        case reminderType   = "reminder_type"
        case reminderTime   = "reminder_time"
        case frequencyType  = "frequency_type"
        case isEnabled      = "is_enabled"
        case lastSentAt     = "last_sent_at"
        case createdAt      = "created_at"
        case updatedAt      = "updated_at"
    }
}
