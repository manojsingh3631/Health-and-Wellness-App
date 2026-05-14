// HomeViewController.swift
// BluePond Wellness

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = HomeViewModel()

    // MARK: - UI

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        let refresh = UIRefreshControl()
        refresh.tintColor = BrandColors.accentBlue
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        sv.refreshControl = refresh
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Header
    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 14)
        l.textColor = BrandColors.steelBlue
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 24)
        l.textColor = BrandColors.white
        return l
    }()

    private let streakBadge: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.label(size: 13)
        l.textColor = BrandColors.amber
        l.backgroundColor = BrandColors.amber.withAlphaComponent(0.15)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }()

    // Challenge Card
    private let challengeCard: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    private let challengeGradient = CAGradientLayer()

    private let challengeTitleLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 18)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    private let challengeDaysLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 13)
        l.textColor = BrandColors.steelBlue
        return l
    }()

    private let pointsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 28)
        l.textColor = BrandColors.teal
        return l
    }()

    private let pointsSubLabel: UILabel = {
        let l = UILabel()
        l.text = "Today's Points"
        l.font = BrandFonts.body(size: 12)
        l.textColor = BrandColors.steelBlue
        return l
    }()

    // Activity Grid
    private let activityGridStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    // Bar Chart
    private let chartContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        v.heightAnchor.constraint(equalToConstant: 140).isActive = true
        return v
    }()

    private let chartStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .bottom
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Rank Card
    private let rankCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }()

    private let rankLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 32)
        l.textColor = BrandColors.accentBlue
        l.textAlignment = .center
        return l
    }()

    private let rankSubLabel: UILabel = {
        let l = UILabel()
        l.text = "Your Rank"
        l.font = BrandFonts.body(size: 12)
        l.textColor = BrandColors.steelBlue
        l.textAlignment = .center
        return l
    }()

    // Nudge Card
    private let nudgeCard: UIView = {
        let v = UIView()
        v.backgroundColor = BrandColors.accentBlue.withAlphaComponent(0.12)
        v.layer.cornerRadius = 14
        v.layer.borderColor = BrandColors.accentBlue.withAlphaComponent(0.3).cgColor
        v.layer.borderWidth = 1
        return v
    }()

    private let nudgeLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 14)
        l.textColor = BrandColors.steelBlue
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
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
        title = "Home"
        view.backgroundColor = BrandColors.deepNavy
        viewModel.delegate = self
        setupLayout()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        challengeGradient.frame = challengeCard.bounds
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

        // Header
        let headerStack = UIStackView(arrangedSubviews: [greetingLabel, nameLabel, streakBadge])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        contentStack.addArrangedSubview(headerStack)

        // Challenge card
        setupChallengeCard()
        contentStack.addArrangedSubview(challengeCard)

        // Activity grid
        contentStack.addArrangedSubview(buildActivityGrid())

        // Bar chart
        setupChartView()
        contentStack.addArrangedSubview(chartContainerView)

        // Rank card
        setupRankCard()
        contentStack.addArrangedSubview(rankCard)

        // Nudge
        setupNudgeCard()
        contentStack.addArrangedSubview(nudgeCard)
    }

    private func setupChallengeCard() {
        challengeGradient.colors = [
            UIColor(hex: "#001A35").cgColor,
            UIColor(hex: "#000D1F").cgColor
        ]
        challengeGradient.startPoint = CGPoint(x: 0, y: 0)
        challengeGradient.endPoint = CGPoint(x: 1, y: 1)
        challengeCard.layer.insertSublayer(challengeGradient, at: 0)

        let cardStack = UIStackView(arrangedSubviews: [challengeTitleLabel, challengeDaysLabel, pointsLabel, pointsSubLabel])
        cardStack.axis = .vertical
        cardStack.spacing = 6
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        challengeCard.addSubview(cardStack)

        NSLayoutConstraint.activate([
            challengeCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            cardStack.topAnchor.constraint(equalTo: challengeCard.topAnchor, constant: 20),
            cardStack.leadingAnchor.constraint(equalTo: challengeCard.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: challengeCard.trailingAnchor, constant: -20),
            cardStack.bottomAnchor.constraint(equalTo: challengeCard.bottomAnchor, constant: -20)
        ])
    }

    private func buildActivityGrid() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 12
        row1.distribution = .fillEqually

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually

        let activities: [(emoji: String, title: String, unit: String)] = [
            ("👟", "Steps", "steps"),
            ("💧", "Water", "liters"),
            ("🧘", "Yoga", "min"),
            ("🏋️", "Workout", "min"),
            ("🍎", "Sugar Free", "day")
        ]

        for (i, activity) in activities.enumerated() {
            let tile = makeActivityTile(emoji: activity.emoji, title: activity.title, unit: activity.unit)
            if i < 3 {
                row1.addArrangedSubview(tile)
            } else {
                row2.addArrangedSubview(tile)
            }
        }

        // Add filler to row2 to balance the 2-tile row
        let filler = UIView()
        row2.addArrangedSubview(filler)

        let gridStack = UIStackView(arrangedSubviews: [row1, row2])
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(gridStack)
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: container.topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeActivityTile(emoji: String, title: String, unit: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = BrandColors.navyCard
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(activityTileTapped(_:)), for: .touchUpInside)
        btn.heightAnchor.constraint(equalToConstant: 88).isActive = true

        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 28)
        emojiLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = BrandFonts.label(size: 12)
        titleLabel.textColor = BrandColors.white
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [emojiLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        btn.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        return btn
    }

    private func setupChartView() {
        let titleLabel = UILabel()
        titleLabel.text = "7-Day Points"
        titleLabel.font = BrandFonts.label(size: 14)
        titleLabel.textColor = BrandColors.steelBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        chartContainerView.addSubview(titleLabel)
        chartContainerView.addSubview(chartStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 16),

            chartStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chartStack.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 16),
            chartStack.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -16),
            chartStack.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -12)
        ])
    }

    private func setupRankCard() {
        rankCard.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [rankLabel, rankSubLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        rankCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: rankCard.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: rankCard.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: rankCard.centerXAnchor)
        ])
    }

    private func setupNudgeCard() {
        nudgeLabel.translatesAutoresizingMaskIntoConstraints = false
        nudgeCard.addSubview(nudgeLabel)
        NSLayoutConstraint.activate([
            nudgeLabel.topAnchor.constraint(equalTo: nudgeCard.topAnchor, constant: 12),
            nudgeLabel.leadingAnchor.constraint(equalTo: nudgeCard.leadingAnchor, constant: 16),
            nudgeLabel.trailingAnchor.constraint(equalTo: nudgeCard.trailingAnchor, constant: -16),
            nudgeLabel.bottomAnchor.constraint(equalTo: nudgeCard.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Data

    private func loadData() {
        loadingIndicator.startAnimating()
        Task {
            await viewModel.loadAll()
        }
    }

    private func updateUI() {
        let participant = viewModel.participant
        let challenge = viewModel.activeChallenge
        let todayLog = viewModel.todayLog

        if let p = participant {
            greetingLabel.text = ShiftAwareUtils.getShiftAwareGreeting(for: p)
            nameLabel.text = p.displayName
            streakBadge.text = " 🔥 \(p.currentStreak) day streak "
        }

        if let c = challenge {
            challengeTitleLabel.text = c.title
            let days = c.daysRemaining
            challengeDaysLabel.text = days == 1 ? "1 day remaining" : "\(days) days remaining"
        } else {
            challengeTitleLabel.text = "No Active Challenge"
            challengeDaysLabel.text = ""
        }

        let pts = todayLog?.pointsEarned ?? 0
        pointsLabel.text = String(format: "%.1f pts", pts)

        // Nudge
        nudgeLabel.text = todayLog == nil
            ? "You haven't logged your activity today. Tap a tile to log now!"
            : "Great job logging today! Keep your streak alive."

        // Bar chart
        buildBarChart(weeklyPoints: viewModel.weeklyPoints)

        rankLabel.text = "#--"
    }

    private func buildBarChart(weeklyPoints: [Double]) {
        chartStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let maxPts = weeklyPoints.max() ?? 1
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date()) - 2 // 0=Mon

        for (i, pts) in weeklyPoints.enumerated() {
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 4

            let fraction = maxPts > 0 ? pts / maxPts : 0
            let barHeight = max(4, 60 * fraction)

            let bar = UIView()
            bar.backgroundColor = i == 6
                ? BrandColors.accentBlue
                : BrandColors.accentBlue.withAlphaComponent(0.4)
            bar.layer.cornerRadius = 4
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
            bar.widthAnchor.constraint(equalToConstant: 20).isActive = true

            let dayLabel = UILabel()
            dayLabel.text = i < days.count ? days[i] : ""
            dayLabel.font = BrandFonts.body(size: 10)
            dayLabel.textColor = BrandColors.steelBlue
            dayLabel.textAlignment = .center

            col.addArrangedSubview(bar)
            col.addArrangedSubview(dayLabel)
            chartStack.addArrangedSubview(col)
        }
    }

    // MARK: - Actions

    @objc private func activityTileTapped(_ sender: UIButton) {
        tabBarController?.selectedIndex = 1
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        Task {
            await viewModel.loadAll()
            await MainActor.run {
                sender.endRefreshing()
            }
        }
    }
}

// MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    func didUpdateData() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.updateUI()
        }
    }

    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
