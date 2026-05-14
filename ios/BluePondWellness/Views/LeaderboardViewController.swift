// LeaderboardViewController.swift
// BluePond Wellness

import UIKit

// MARK: - LeaderboardCell

final class LeaderboardCell: UITableViewCell {

    static let reuseIdentifier = "LeaderboardCell"

    private let rankLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 18)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.backgroundColor = BrandColors.accentBlue.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 15)
        l.textColor = BrandColors.white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.label(size: 15)
        l.textColor = BrandColors.white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let deptLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 12)
        l.textColor = BrandColors.steelBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pointsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 16)
        l.textColor = BrandColors.teal
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = BrandColors.navyCard
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        avatarView.addSubview(initialsLabel)
        NSLayoutConstraint.activate([
            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, deptLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(rankLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameStack)
        contentView.addSubview(pointsLabel)

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 36),

            avatarView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),

            nameStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            nameStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameStack.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -8),

            pointsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pointsLabel.widthAnchor.constraint(equalToConstant: 80),

            contentView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    func configure(entry: LeaderboardEntry, isCurrentUser: Bool) {
        // Rank styling
        let rank = entry.rank
        switch rank {
        case 1:
            rankLabel.text = "🥇"
            rankLabel.font = .systemFont(ofSize: 22)
        case 2:
            rankLabel.text = "🥈"
            rankLabel.font = .systemFont(ofSize: 22)
        case 3:
            rankLabel.text = "🥉"
            rankLabel.font = .systemFont(ofSize: 22)
        default:
            rankLabel.text = "#\(rank)"
            rankLabel.font = BrandFonts.label(size: 14)
            rankLabel.textColor = entry.isTied ? BrandColors.amber : BrandColors.steelBlue
        }

        nameLabel.text = entry.displayName
        deptLabel.text = entry.department ?? entry.teamName ?? ""
        pointsLabel.text = String(format: "%.1f", entry.totalPoints)

        // Initials
        let parts = entry.displayName.split(separator: " ").map(String.init)
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        initialsLabel.text = "\(first)\(last)".uppercased()

        // Highlight current user
        if isCurrentUser {
            backgroundColor = BrandColors.accentBlue.withAlphaComponent(0.18)
            layer.borderColor = BrandColors.accentBlue.withAlphaComponent(0.4).cgColor
            layer.borderWidth = 1
        } else {
            backgroundColor = BrandColors.navyCard
            layer.borderWidth = 0
        }
    }
}

// MARK: - LeaderboardViewController

final class LeaderboardViewController: UIViewController {

    private let viewModel = LeaderboardViewModel()

    // MARK: - UI

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Weekly", "Monthly", "Period", "Team"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = BrandColors.navyCard
        sc.selectedSegmentTintColor = BrandColors.accentBlue
        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: BrandColors.steelBlue,
            .font: BrandFonts.label(size: 13)
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: BrandColors.white,
            .font: BrandFonts.label(size: 13)
        ]
        sc.setTitleTextAttributes(normalAttr, for: .normal)
        sc.setTitleTextAttributes(selectedAttr, for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = BrandColors.deepNavy
        tv.separatorStyle = .none
        tv.rowHeight = 64
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        let refresh = UIRefreshControl()
        refresh.tintColor = BrandColors.accentBlue
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tv.refreshControl = refresh
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No leaderboard data available."
        l.font = BrandFonts.body(size: 15)
        l.textColor = BrandColors.steelBlue
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

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
        title = "Leaderboard"
        view.backgroundColor = BrandColors.deepNavy
        viewModel.delegate = self
        setupLayout()
        loadData()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Data

    private func loadData() {
        loadingIndicator.startAnimating()
        Task {
            await viewModel.loadLeaderboard()
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let types = ["Weekly", "Monthly", "Period", "Team"]
        let type = types[sender.selectedSegmentIndex]
        loadingIndicator.startAnimating()
        Task {
            await viewModel.switchType(type)
        }
    }

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        Task {
            await viewModel.loadLeaderboard()
            await MainActor.run { sender.endRefreshing() }
        }
    }
}

// MARK: - UITableViewDataSource

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.reuseIdentifier, for: indexPath) as! LeaderboardCell
        let entry = viewModel.entries[indexPath.row]
        let isCurrentUser = entry.participantId == SessionManager.shared.participantId
        cell.configure(entry: entry, isCurrentUser: isCurrentUser)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LeaderboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - LeaderboardViewModelDelegate

extension LeaderboardViewController: LeaderboardViewModelDelegate {
    func leaderboardDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.loadingIndicator.stopAnimating()
            self.emptyLabel.isHidden = !self.viewModel.entries.isEmpty
            self.tableView.reloadData()
        }
    }

    func leaderboardDidFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
