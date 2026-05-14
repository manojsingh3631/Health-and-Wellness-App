// HomeViewModel.swift
// BluePond Wellness

import Foundation

// MARK: - Delegate Protocol

protocol HomeViewModelDelegate: AnyObject {
    func didUpdateData()
    func didFailWithError(_ error: Error)
}

// MARK: - HomeViewModel

final class HomeViewModel {

    weak var delegate: HomeViewModelDelegate?

    var activeChallenge: Challenge?
    var todayLog: ActivityLog?
    var participant: Participant?
    var weeklyPoints: [Double] = Array(repeating: 0.0, count: 7)
    var isLoading: Bool = false

    // MARK: - Load All Data

    func loadAll() async {
        isLoading = true

        do {
            guard let participantId = SessionManager.shared.participantId,
                  let userId = SessionManager.shared.userId else {
                throw SupabaseError.authError("No participant session found")
            }

            // Load participant profile
            let p = try await SupabaseService.shared.fetchParticipant(authUserId: userId)
            self.participant = p

            // Load active challenge
            let challenges = try await SupabaseService.shared.getActiveChallenges()
            guard let challenge = challenges.first else {
                self.activeChallenge = nil
                self.isLoading = false
                await notifyDelegate()
                return
            }
            self.activeChallenge = challenge

            // Load today's activity log
            let todayDateString = ShiftAwareUtils.getActiveDateString(for: p)
            let logs = try await SupabaseService.shared.getActivityLogs(
                participantId: participantId,
                challengeId: challenge.id
            )

            self.todayLog = logs.first(where: { $0.activityDate == todayDateString })

            // Build 7-day weekly points array (most recent 7 days, index 0 = oldest)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current

            var daily = [Double](repeating: 0, count: 7)
            let calendar = Calendar.current

            for log in logs where !log.isVoided {
                guard let logDate = formatter.date(from: log.activityDate) else { continue }
                let daysAgo = calendar.dateComponents([.day], from: logDate, to: Date()).day ?? Int.max
                if daysAgo >= 0 && daysAgo < 7 {
                    let index = 6 - daysAgo
                    daily[index] += log.pointsEarned
                }
            }
            self.weeklyPoints = daily

            isLoading = false
            await notifyDelegate()

        } catch {
            isLoading = false
            await notifyDelegateError(error)
        }
    }

    // MARK: - Private

    @MainActor
    private func notifyDelegate() {
        delegate?.didUpdateData()
    }

    @MainActor
    private func notifyDelegateError(_ error: Error) {
        delegate?.didFailWithError(error)
    }
}
