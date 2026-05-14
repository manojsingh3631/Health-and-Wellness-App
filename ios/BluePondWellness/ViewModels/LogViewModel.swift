// LogViewModel.swift
// BluePond Wellness

import Foundation

// MARK: - Delegate Protocol

protocol LogViewModelDelegate: AnyObject {
    func logViewModelDidLoadData()
    func logViewModelDidFailWithError(_ error: Error)
}

// MARK: - LogViewModel

final class LogViewModel {

    weak var delegate: LogViewModelDelegate?

    var existingLog: ActivityLog?
    var activeChallenge: Challenge?
    var scoringConfigs: [ScoringConfig] = []
    var estimatedPoints: Double = 0
    var isLoading: Bool = false

    // MARK: - Load Data

    func loadData() async {
        isLoading = true
        do {
            guard let participantId = SessionManager.shared.participantId,
                  let userId = SessionManager.shared.userId else {
                throw SupabaseError.authError("No session found")
            }

            let participant = try await SupabaseService.shared.fetchParticipant(authUserId: userId)

            let challenges = try await SupabaseService.shared.getActiveChallenges()
            guard let challenge = challenges.first else {
                isLoading = false
                await notifyLoaded()
                return
            }
            self.activeChallenge = challenge

            // Load scoring config
            self.scoringConfigs = try await SupabaseService.shared.getScoringConfig(
                challengeId: challenge.id
            )

            // Load today's existing log
            let todayDate = ShiftAwareUtils.getActiveDateString(for: participant)
            let logs = try await SupabaseService.shared.getActivityLogs(
                participantId: participantId,
                challengeId: challenge.id
            )
            self.existingLog = logs.first(where: { $0.activityDate == todayDate })

            isLoading = false
            await notifyLoaded()

        } catch {
            isLoading = false
            await notifyError(error)
        }
    }

    // MARK: - Estimate Points

    func calculateEstimatedPoints(
        steps: Int,
        water: Double,
        yoga: Int,
        workout: Int,
        sugarFree: Bool
    ) -> Double {
        guard let challenge = activeChallenge,
              let participantId = SessionManager.shared.participantId else {
            return 0
        }

        let tempLog = ActivityLog(
            id: nil,
            participantId: participantId,
            challengeId: challenge.id,
            activityDate: "",
            stepsCount: steps,
            waterIntakeLiters: water,
            yogaMinutes: yoga,
            workoutMinutes: workout,
            noAddedSugarDay: sugarFree,
            pointsEarned: 0,
            editCount: 0,
            dataSource: "manual",
            status: "submitted",
            isVoided: false,
            submittedAt: nil,
            lastModifiedAt: nil
        )

        let pts = ScoringEngine.calculatePoints(
            log: tempLog,
            configs: scoringConfigs,
            challenge: challenge
        )
        self.estimatedPoints = pts
        return pts
    }

    // MARK: - Submit Log

    func submitLog(
        steps: Int,
        water: Double,
        yoga: Int,
        workout: Int,
        sugarFree: Bool
    ) async -> Result<ActivityLog, Error> {
        guard let challenge = activeChallenge,
              let participantId = SessionManager.shared.participantId,
              let userId = SessionManager.shared.userId else {
            return .failure(SupabaseError.authError("No session"))
        }

        do {
            let participant = try await SupabaseService.shared.fetchParticipant(authUserId: userId)
            let todayDate = ShiftAwareUtils.getActiveDateString(for: participant)

            let points = calculateEstimatedPoints(
                steps: steps, water: water, yoga: yoga,
                workout: workout, sugarFree: sugarFree
            )

            let isoFormatter = ISO8601DateFormatter()
            let now = isoFormatter.string(from: Date())

            let log = ActivityLog(
                id: nil,
                participantId: participantId,
                challengeId: challenge.id,
                activityDate: todayDate,
                stepsCount: steps,
                waterIntakeLiters: water,
                yogaMinutes: yoga,
                workoutMinutes: workout,
                noAddedSugarDay: sugarFree,
                pointsEarned: points,
                editCount: 0,
                dataSource: "manual",
                status: "submitted",
                isVoided: false,
                submittedAt: now,
                lastModifiedAt: now
            )

            let created = try await SupabaseService.shared.submitActivityLog(log)
            return .success(created)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Update Log

    func updateLog(
        steps: Int,
        water: Double,
        yoga: Int,
        workout: Int,
        sugarFree: Bool
    ) async -> Result<ActivityLog, Error> {
        guard var log = existingLog else {
            return .failure(SupabaseError.serverError(400, "No existing log to update"))
        }
        guard log.canEdit else {
            return .failure(SupabaseError.serverError(403, "Log cannot be edited"))
        }

        let points = calculateEstimatedPoints(
            steps: steps, water: water, yoga: yoga,
            workout: workout, sugarFree: sugarFree
        )

        let isoFormatter = ISO8601DateFormatter()

        log.stepsCount          = steps
        log.waterIntakeLiters   = water
        log.yogaMinutes         = yoga
        log.workoutMinutes      = workout
        log.noAddedSugarDay     = sugarFree
        log.pointsEarned        = points
        log.editCount          += 1
        log.lastModifiedAt      = isoFormatter.string(from: Date())

        do {
            try await SupabaseService.shared.updateActivityLog(log)
            self.existingLog = log
            return .success(log)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private

    @MainActor
    private func notifyLoaded() {
        delegate?.logViewModelDidLoadData()
    }

    @MainActor
    private func notifyError(_ error: Error) {
        delegate?.logViewModelDidFailWithError(error)
    }
}
