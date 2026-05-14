// ScoringEngine.swift
// BluePond Wellness

import Foundation

struct ScoringEngine {

    // MARK: - Point Calculation

    /// Calculates total points for a given activity log based on challenge scoring configs.
    /// Logic mirrors the Android implementation:
    ///   earned = floor(value / threshold) * pointsPerUnit, capped at dailyMaxPoints
    ///   if value >= bonusThreshold, add bonusPoints
    static func calculatePoints(
        log: ActivityLog,
        configs: [ScoringConfig],
        challenge: Challenge
    ) -> Double {
        var totalPoints: Double = 0

        for config in configs where config.isActive {
            let activityPoints: Double

            switch config.activityType.lowercased() {

            case "steps":
                guard challenge.includeSteps else { continue }
                let units = floor(Double(log.stepsCount) / config.unitThreshold)
                var pts = units * config.pointsPerUnit
                pts = min(pts, config.dailyMaxPoints)
                if let bonusThreshold = config.bonusThreshold,
                   let bonusPoints = config.bonusPoints,
                   Double(log.stepsCount) >= bonusThreshold {
                    pts += bonusPoints
                }
                activityPoints = pts

            case "water":
                guard challenge.includeWater else { continue }
                let units = floor(log.waterIntakeLiters / config.unitThreshold)
                var pts = units * config.pointsPerUnit
                pts = min(pts, config.dailyMaxPoints)
                if let bonusThreshold = config.bonusThreshold,
                   let bonusPoints = config.bonusPoints,
                   log.waterIntakeLiters >= bonusThreshold {
                    pts += bonusPoints
                }
                activityPoints = pts

            case "yoga":
                guard challenge.includeYoga else { continue }
                let units = floor(Double(log.yogaMinutes) / config.unitThreshold)
                var pts = units * config.pointsPerUnit
                pts = min(pts, config.dailyMaxPoints)
                if let bonusThreshold = config.bonusThreshold,
                   let bonusPoints = config.bonusPoints,
                   Double(log.yogaMinutes) >= bonusThreshold {
                    pts += bonusPoints
                }
                activityPoints = pts

            case "workout":
                guard challenge.includeWorkout else { continue }
                let units = floor(Double(log.workoutMinutes) / config.unitThreshold)
                var pts = units * config.pointsPerUnit
                pts = min(pts, config.dailyMaxPoints)
                if let bonusThreshold = config.bonusThreshold,
                   let bonusPoints = config.bonusPoints,
                   Double(log.workoutMinutes) >= bonusThreshold {
                    pts += bonusPoints
                }
                activityPoints = pts

            case "sugar_free", "sugarfree", "no_added_sugar":
                guard challenge.includeSugarFree else { continue }
                activityPoints = log.noAddedSugarDay ? config.dailyMaxPoints : 0

            default:
                continue
            }

            totalPoints += activityPoints
        }

        return totalPoints
    }

    // MARK: - Streak Bonus

    /// Returns bonus points based on current streak milestones.
    static func getStreakBonus(
        streak: Int,
        sevenDayBonus: Double,
        thirtyDayBonus: Double
    ) -> Double {
        if streak > 0 && streak % 30 == 0 {
            return thirtyDayBonus
        } else if streak > 0 && streak % 7 == 0 {
            return sevenDayBonus
        }
        return 0
    }
}
