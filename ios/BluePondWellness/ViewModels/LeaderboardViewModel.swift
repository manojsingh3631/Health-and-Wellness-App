// LeaderboardViewModel.swift
// BluePond Wellness

import Foundation

// MARK: - Delegate Protocol

protocol LeaderboardViewModelDelegate: AnyObject {
    func leaderboardDidUpdate()
    func leaderboardDidFailWithError(_ error: Error)
}

// MARK: - LeaderboardViewModel

final class LeaderboardViewModel {

    weak var delegate: LeaderboardViewModelDelegate?

    var entries: [LeaderboardEntry] = []
    var selectedType: String = "Weekly"
    var isLoading: Bool = false
    private var activeChallengeId: String?

    // MARK: - Load Leaderboard

    func loadLeaderboard() async {
        isLoading = true

        do {
            // Get active challenge if not cached
            if activeChallengeId == nil {
                let challenges = try await SupabaseService.shared.getActiveChallenges()
                activeChallengeId = challenges.first?.id
            }

            guard let challengeId = activeChallengeId else {
                isLoading = false
                await notifyUpdate()
                return
            }

            self.entries = try await SupabaseService.shared.getLeaderboard(
                challengeId: challengeId,
                type: selectedType
            )
            isLoading = false
            await notifyUpdate()

        } catch {
            isLoading = false
            await notifyError(error)
        }
    }

    // MARK: - Switch Type

    func switchType(_ type: String) async {
        selectedType = type
        await loadLeaderboard()
    }

    // MARK: - Private

    @MainActor
    private func notifyUpdate() {
        delegate?.leaderboardDidUpdate()
    }

    @MainActor
    private func notifyError(_ error: Error) {
        delegate?.leaderboardDidFailWithError(error)
    }
}
