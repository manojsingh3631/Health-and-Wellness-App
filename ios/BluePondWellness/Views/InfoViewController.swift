// InfoViewController.swift
// BluePond Wellness

import UIKit

// MARK: - FAQCell

final class FAQCell: UITableViewCell {

    static let reuseIdentifier = "FAQCell"

    var isExpanded: Bool = false {
        didSet { answerLabel.isHidden = !isExpanded }
    }

    private let questionLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.white
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let answerLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 13)
        l.textColor = BrandColors.steelBlue
        l.numberOfLines = 0
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevronLabel: UILabel = {
        let l = UILabel()
        l.text = "›"
        l.font = BrandFonts.heading(size: 18)
        l.textColor = BrandColors.steelBlue
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
        let textStack = UIStackView(arrangedSubviews: [questionLabel, answerLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textStack)
        contentView.addSubview(chevronLabel)

        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: chevronLabel.leadingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            chevronLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronLabel.centerYAnchor.constraint(equalTo: questionLabel.centerYAnchor),
            chevronLabel.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(faq: FAQ, expanded: Bool) {
        questionLabel.text = faq.question
        answerLabel.text = faq.answer
        isExpanded = expanded
        chevronLabel.transform = expanded
            ? CGAffineTransform(rotationAngle: .pi / 2)
            : .identity
    }
}

// MARK: - InfoViewController

final class InfoViewController: UIViewController {

    // MARK: - Data

    private var faqs: [FAQ] = []
    private var expandedFAQIndexes: Set<Int> = []

    // MARK: - UI

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["FAQs", "Rules", "Privacy", "Consent"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = BrandColors.navyCard
        sc.selectedSegmentTintColor = BrandColors.accentBlue
        let normal:   [NSAttributedString.Key: Any] = [.foregroundColor: BrandColors.steelBlue, .font: BrandFonts.label(size: 13)]
        let selected: [NSAttributedString.Key: Any] = [.foregroundColor: BrandColors.white,     .font: BrandFonts.label(size: 13)]
        sc.setTitleTextAttributes(normal, for: .normal)
        sc.setTitleTextAttributes(selected, for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // FAQs panel
    private lazy var faqTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = BrandColors.deepNavy
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(FAQCell.self, forCellReuseIdentifier: FAQCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    // Rules panel
    private lazy var rulesScrollView: UIScrollView = makeScrollPanel()
    private lazy var rulesStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Privacy panel
    private lazy var privacyScrollView: UIScrollView = makeScrollPanel()
    private lazy var privacyLabel: UILabel = makeBodyLabel(text: privacyText)

    // Consent panel
    private lazy var consentScrollView: UIScrollView = makeScrollPanel()
    private lazy var consentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Info"
        view.backgroundColor = BrandColors.deepNavy
        setupLayout()
        setupRulesContent()
        setupPrivacyContent()
        setupConsentContent()
        loadFAQs()
        showPanel(index: 0)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add panels to container
        [faqTableView, rulesScrollView, privacyScrollView, consentScrollView].forEach { panel in
            containerView.addSubview(panel)
            NSLayoutConstraint.activate([
                panel.topAnchor.constraint(equalTo: containerView.topAnchor),
                panel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                panel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                panel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

        // Rules scroll content
        rulesScrollView.addSubview(rulesStack)
        NSLayoutConstraint.activate([
            rulesStack.topAnchor.constraint(equalTo: rulesScrollView.topAnchor, constant: 16),
            rulesStack.leadingAnchor.constraint(equalTo: rulesScrollView.leadingAnchor, constant: 16),
            rulesStack.trailingAnchor.constraint(equalTo: rulesScrollView.trailingAnchor, constant: -16),
            rulesStack.bottomAnchor.constraint(equalTo: rulesScrollView.bottomAnchor, constant: -24),
            rulesStack.widthAnchor.constraint(equalTo: rulesScrollView.widthAnchor, constant: -32)
        ])

        // Privacy scroll content
        privacyScrollView.addSubview(privacyLabel)
        NSLayoutConstraint.activate([
            privacyLabel.topAnchor.constraint(equalTo: privacyScrollView.topAnchor, constant: 16),
            privacyLabel.leadingAnchor.constraint(equalTo: privacyScrollView.leadingAnchor, constant: 16),
            privacyLabel.trailingAnchor.constraint(equalTo: privacyScrollView.trailingAnchor, constant: -16),
            privacyLabel.bottomAnchor.constraint(equalTo: privacyScrollView.bottomAnchor, constant: -24),
            privacyLabel.widthAnchor.constraint(equalTo: privacyScrollView.widthAnchor, constant: -32)
        ])

        // Consent scroll content
        consentScrollView.addSubview(consentStack)
        NSLayoutConstraint.activate([
            consentStack.topAnchor.constraint(equalTo: consentScrollView.topAnchor, constant: 16),
            consentStack.leadingAnchor.constraint(equalTo: consentScrollView.leadingAnchor, constant: 16),
            consentStack.trailingAnchor.constraint(equalTo: consentScrollView.trailingAnchor, constant: -16),
            consentStack.bottomAnchor.constraint(equalTo: consentScrollView.bottomAnchor, constant: -24),
            consentStack.widthAnchor.constraint(equalTo: consentScrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Panel Content Setup

    private func setupRulesContent() {
        let titleLabel = makeHeadingLabel(text: "Challenge Rules & Scoring")
        rulesStack.addArrangedSubview(titleLabel)
        rulesStack.setCustomSpacing(16, after: titleLabel)

        let activities: [(String, String, String)] = [
            ("👟 Steps",      "Points Per",     "Daily Max"),
            ("💧 Water (L)",  "Points Per L",   "Daily Max"),
            ("🧘 Yoga (min)", "Points/30 min",  "Daily Max"),
            ("🏋 Workout",    "Points/30 min",  "Daily Max"),
            ("🍎 Sugar Free", "Fixed",          "—")
        ]

        let headerRow = makeTableRow(col1: "Activity", col2: "Earning", col3: "Cap", isHeader: true)
        rulesStack.addArrangedSubview(headerRow)

        for (a, b, c) in activities {
            rulesStack.addArrangedSubview(makeTableRow(col1: a, col2: b, col3: c, isHeader: false))
        }

        rulesStack.setCustomSpacing(20, after: rulesStack.arrangedSubviews.last ?? UIView())

        let notesLabel = makeBodyLabel(text: "• Each activity type has configurable thresholds and bonus points set by your Wellness Coordinator.\n• You may edit a submission once per day before midnight.\n• Streak bonuses apply at 7-day and 30-day milestones.\n• All submissions are final after the deadline.")
        rulesStack.addArrangedSubview(notesLabel)
    }

    private func setupPrivacyContent() {
        privacyLabel.text = privacyText
    }

    private func setupConsentContent() {
        let sm = SessionManager.shared
        let items: [(String, String)] = [
            ("Participant",     sm.displayName ?? "--"),
            ("Email",          sm.participantEmail ?? "--"),
            ("Consent",        "Accepted"),
            ("Date",           "On file"),
            ("Data Usage",     "Activity data is used only for wellness program scoring and reporting within your organization."),
            ("Retention",      "Data is retained for the duration of the program and up to 1 year after."),
            ("Your Rights",    "You may request data export or deletion via your HR department.")
        ]

        let title = makeHeadingLabel(text: "Consent Record")
        consentStack.addArrangedSubview(title)

        for (label, value) in items {
            let row = UIStackView()
            row.axis = .vertical
            row.spacing = 2

            let lbl = UILabel()
            lbl.text = label
            lbl.font = BrandFonts.label(size: 12)
            lbl.textColor = BrandColors.steelBlue

            let val = UILabel()
            val.text = value
            val.font = BrandFonts.body(size: 14)
            val.textColor = BrandColors.white
            val.numberOfLines = 0

            row.addArrangedSubview(lbl)
            row.addArrangedSubview(val)

            let separator = UIView()
            separator.backgroundColor = BrandColors.mutedBlue.withAlphaComponent(0.2)
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

            consentStack.addArrangedSubview(row)
            consentStack.addArrangedSubview(separator)
        }
    }

    // MARK: - Data

    private func loadFAQs() {
        Task {
            if let loaded = try? await SupabaseService.shared.getFaqs() {
                await MainActor.run { [weak self] in
                    self?.faqs = loaded
                    self?.faqTableView.reloadData()
                }
            }
        }
    }

    // MARK: - Panel Switch

    private func showPanel(index: Int) {
        let panels: [UIView] = [faqTableView, rulesScrollView, privacyScrollView, consentScrollView]
        panels.enumerated().forEach { i, panel in
            panel.isHidden = i != index
        }
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        showPanel(index: sender.selectedSegmentIndex)
    }

    // MARK: - Helpers

    private func makeScrollPanel() -> UIScrollView {
        let sv = UIScrollView()
        sv.backgroundColor = BrandColors.deepNavy
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }

    private func makeBodyLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = BrandFonts.body(size: 14)
        l.textColor = BrandColors.steelBlue
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeHeadingLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = BrandFonts.heading(size: 18)
        l.textColor = BrandColors.white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeTableRow(col1: String, col2: String, col3: String, isHeader: Bool) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.backgroundColor = isHeader ? BrandColors.accentBlue.withAlphaComponent(0.2) : .clear
        row.layer.cornerRadius = isHeader ? 8 : 0

        [col1, col2, col3].forEach { text in
            let l = UILabel()
            l.text = text
            l.font = isHeader ? BrandFonts.label(size: 13) : BrandFonts.body(size: 13)
            l.textColor = isHeader ? BrandColors.white : BrandColors.steelBlue
            l.textAlignment = .center
            l.numberOfLines = 1
            row.addArrangedSubview(l)
        }

        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return row
    }

    private var privacyText: String {
        return """
        Privacy Policy — BluePond Wellness

        Last updated: 2024

        1. Data We Collect
        We collect activity data (steps, water intake, yoga, workout minutes, sugar-free days), profile information (name, department, shift), and device identifiers for push notifications.

        2. How We Use Your Data
        Your data is used solely for:
        • Calculating wellness challenge points and leaderboard rankings
        • Generating anonymized organizational health reports
        • Sending activity reminders and streak notifications

        3. Data Sharing
        Your individual data is never sold or shared with third parties. Aggregated, anonymized data may be shared with your employer for wellness program reporting.

        4. Data Security
        All data is encrypted in transit (TLS 1.2+) and at rest. Access is restricted to authorized personnel only.

        5. Your Rights
        You may request a copy of your data or request deletion at any time by contacting your HR department or emailing wellness@bluepond.ai.

        6. Retention
        Data is retained for the duration of active challenges and up to 12 months after program completion.

        7. Contact
        For privacy inquiries: wellness@bluepond.ai
        """
    }
}

// MARK: - UITableViewDataSource

extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        faqs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FAQCell.reuseIdentifier, for: indexPath) as! FAQCell
        cell.configure(faq: faqs[indexPath.row], expanded: expandedFAQIndexes.contains(indexPath.row))
        return cell
    }
}

// MARK: - UITableViewDelegate

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedFAQIndexes.contains(indexPath.row) {
            expandedFAQIndexes.remove(indexPath.row)
        } else {
            expandedFAQIndexes.insert(indexPath.row)
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
