// ProgressViewController.swift
// BluePond Wellness

import UIKit

final class ProgressViewController: UIViewController {

    // MARK: - State

    private var participant: Participant?
    private var activityLogs: [ActivityLog] = []
    private var challenge: Challenge?

    // MARK: - UI

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        let refresh = UIRefreshControl()
        refresh.tintColor = BrandColors.accentBlue
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        sv.refreshControl = refresh
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Streak card
    private let streakCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }()

    private let currentStreakLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 40)
        l.textColor = BrandColors.amber
        l.textAlignment = .center
        return l
    }()

    private let longestStreakLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        l.textAlignment = .center
        return l
    }()

    // Total points card
    private let totalPointsCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }()

    private let totalPointsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 40)
        l.textColor = BrandColors.teal
        l.textAlignment = .center
        return l
    }()

    private let totalPointsSubLabel: UILabel = {
        let l = UILabel()
        l.text = "Total Points Earned"
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        l.textAlignment = .center
        return l
    }()

    // Chart card
    private let chartCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }()

    private let chartTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Daily Points (Last 14 Days)"
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        return l
    }()

    private let chartBarStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .bottom
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Activity breakdown card
    private let breakdownCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }()

    private let breakdownStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Loading
    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = BrandColors.accentBlue
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress"
        view.backgroundColor = BrandColors.deepNavy
        setupLayout()
        loadData()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Streak card layout
        buildStreakCard()
        contentStack.addArrangedSubview(streakCard)

        // Points card layout
        buildTotalPointsCard()
        contentStack.addArrangedSubview(totalPointsCard)

        // Chart card
        buildChartCard()
        contentStack.addArrangedSubview(chartCard)

        // Breakdown card
        buildBreakdownCard()
        contentStack.addArrangedSubview(breakdownCard)
    }

    private func buildStreakCard() {
        let fireLabel = UILabel()
        fireLabel.text = "🔥"
        fireLabel.font = .systemFont(ofSize: 36)
        fireLabel.textAlignment = .center

        let streakSubLabel = UILabel()
        streakSubLabel.text = "Current Streak"
        streakSubLabel.font = BrandFonts.body(size: 12)
        streakSubLabel.textColor = BrandColors.steelBlue
        streakSubLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [fireLabel, currentStreakLabel, streakSubLabel, longestStreakLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        streakCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildTotalPointsCard() {
        let stack = UIStackView(arrangedSubviews: [totalPointsLabel, totalPointsSubLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        totalPointsCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: totalPointsCard.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: totalPointsCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: totalPointsCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: totalPointsCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildChartCard() {
        let outerStack = UIStackView(arrangedSubviews: [chartTitleLabel, chartBarStack])
        outerStack.axis = .vertical
        outerStack.spacing = 8
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        chartBarStack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        chartCard.addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 16),
            outerStack.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 16),
            outerStack.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -16),
            outerStack.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildBreakdownCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Activity Totals"
        titleLabel.font = BrandFonts.heading(size: 15)
        titleLabel.textColor = BrandColors.white

        breakdownStack.addArrangedSubview(titleLabel)

        let outerStack = UIStackView(arrangedSubviews: [breakdownStack])
        outerStack.axis = .vertical
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        breakdownCard.addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: breakdownCard.topAnchor, constant: 16),
            outerStack.leadingAnchor.constraint(equalTo: breakdownCard.leadingAnchor, constant: 16),
            outerStack.trailingAnchor.constraint(equalTo: breakdownCard.trailingAnchor, constant: -16),
            outerStack.bottomAnchor.constraint(equalTo: breakdownCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Data

    private func loadData() {
        guard let userId = SessionManager.shared.userId,
              let participantId = SessionManager.shared.participantId else { return }
        loadingIndicator.startAnimating()

        Task {
            do {
                let p = try await SupabaseService.shared.fetchParticipant(authUserId: userId)
                self.participant = p

                let challenges = try await SupabaseService.shared.getActiveChallenges()
                if let challenge = challenges.first {
                    self.challenge = challenge
                    self.activityLogs = try await SupabaseService.shared.getActivityLogs(
                        participantId: participantId,
                        challengeId: challenge.id
                    )
                }

                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.updateUI()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    private func updateUI() {
        guard let p = participant else { return }

        currentStreakLabel.text = "\(p.currentStreak) days"
        longestStreakLabel.text = "Best: \(p.longestStreak) days"

        let validLogs = activityLogs.filter { !$0.isVoided }
        let totalPts = validLogs.reduce(0.0) { $0 + $1.pointsEarned }
        totalPointsLabel.text = String(format: "%.1f pts", totalPts)

        buildChart(logs: validLogs)
        buildBreakdownRows(logs: validLogs)
    }

    private func buildChart(logs: [ActivityLog]) {
        chartBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current

        var dailyPoints = [Double](repeating: 0, count: 14)
        for log in logs {
            guard let date = formatter.date(from: log.activityDate) else { continue }
            let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? Int.max
            if daysAgo >= 0 && daysAgo < 14 {
                dailyPoints[13 - daysAgo] += log.pointsEarned
            }
        }

        let maxPts = dailyPoints.max() ?? 1

        for (i, pts) in dailyPoints.enumerated() {
            let fraction = maxPts > 0 ? pts / maxPts : 0
            let barHeight = max(4, 70 * fraction)

            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 2

            let bar = UIView()
            bar.backgroundColor = i == 13
                ? BrandColors.teal
                : BrandColors.accentBlue.withAlphaComponent(0.45)
            bar.layer.cornerRadius = 3
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
            bar.widthAnchor.constraint(equalToConstant: 14).isActive = true

            col.addArrangedSubview(bar)
            chartBarStack.addArrangedSubview(col)
        }
    }

    private func buildBreakdownRows(logs: [ActivityLog]) {
        // Remove existing rows except title
        while breakdownStack.arrangedSubviews.count > 1 {
            breakdownStack.arrangedSubviews.last.map { breakdownStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        }

        let totalSteps   = logs.reduce(0) { $0 + $1.stepsCount }
        let totalWater   = logs.reduce(0.0) { $0 + $1.waterIntakeLiters }
        let totalYoga    = logs.reduce(0) { $0 + $1.yogaMinutes }
        let totalWorkout = logs.reduce(0) { $0 + $1.workoutMinutes }
        let sugarFreeDays = logs.filter { $0.noAddedSugarDay }.count

        let rows: [(String, String)] = [
            ("👟 Total Steps",       "\(totalSteps.formatted())"),
            ("💧 Water Intake",      String(format: "%.1f L", totalWater)),
            ("🧘 Yoga Minutes",      "\(totalYoga) min"),
            ("🏋️ Workout Minutes",   "\(totalWorkout) min"),
            ("🍎 Sugar-Free Days",   "\(sugarFreeDays) days")
        ]

        for (label, value) in rows {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing

            let lbl = UILabel()
            lbl.text = label
            lbl.font = BrandFonts.body(size: 14)
            lbl.textColor = BrandColors.steelBlue

            let val = UILabel()
            val.text = value
            val.font = BrandFonts.label(size: 14)
            val.textColor = BrandColors.white

            row.addArrangedSubview(lbl)
            row.addArrangedSubview(val)
            breakdownStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        loadData()
        sender.endRefreshing()
    }
}
