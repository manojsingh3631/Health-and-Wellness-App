// ShiftAwareUtils.swift
// BluePond Wellness

import Foundation

struct ShiftAwareUtils {

    // MARK: - Active Date

    /// Returns the "active" date string (yyyy-MM-dd) accounting for night-shift crossing midnight.
    static func getActiveDateString(for participant: Participant) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        guard participant.shiftType.lowercased().contains("night"),
              let endTimeString = participant.shiftEndTime,
              let shiftEndHour = parseHour(from: endTimeString) else {
            return formatter.string(from: Date())
        }

        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())

        // Night shift workers: if current time is before shift end (e.g. before 06:00),
        // the "active day" is yesterday.
        if currentHour < shiftEndHour {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            return formatter.string(from: yesterday)
        } else {
            return formatter.string(from: Date())
        }
    }

    // MARK: - Greeting

    static func getShiftAwareGreeting(for participant: Participant) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let isNight = participant.shiftType.lowercased().contains("night")

        if isNight {
            // Invert typical greetings for night shift workers
            switch hour {
            case 0..<6:   return "Good Evening"
            case 6..<12:  return "Good Night"
            case 12..<18: return "Good Morning"
            default:      return "Good Afternoon"
            }
        } else {
            switch hour {
            case 5..<12:  return "Good Morning"
            case 12..<17: return "Good Afternoon"
            case 17..<21: return "Good Evening"
            default:      return "Good Night"
            }
        }
    }

    // MARK: - Quiet Hours

    /// For night shift workers, quiet hours are 09:00–18:00 (their sleep time).
    /// For regular shift workers, quiet hours are 22:00–06:00.
    static func isQuietHours(for participant: Participant) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let isNight = participant.shiftType.lowercased().contains("night")

        if isNight {
            return hour >= 9 && hour < 18
        } else {
            return hour >= 22 || hour < 6
        }
    }

    // MARK: - Format Shift Type

    static func formatShiftType(_ type: String) -> String {
        switch type.lowercased() {
        case "morning", "day":     return "Morning Shift"
        case "afternoon", "eve":   return "Afternoon Shift"
        case "night":              return "Night Shift"
        case "rotating":           return "Rotating Shift"
        case "flexible", "flex":   return "Flexible Shift"
        default:
            // Title-case the raw value
            return type
                .split(separator: "_")
                .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                .joined(separator: " ")
        }
    }

    // MARK: - Private Helpers

    private static func parseHour(from timeString: String) -> Int? {
        // Accepts "HH:mm" or "HH:mm:ss"
        let parts = timeString.split(separator: ":").map(String.init)
        guard let hourString = parts.first, let hour = Int(hourString) else {
            return nil
        }
        return hour
    }
}
