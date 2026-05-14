// ProfileViewController.swift
// BluePond Wellness

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - State

    private var participant: Participant?
    private var reminders: [Reminder] = []
    private var selectedShiftType: String = "Day"
    private let shiftTypes = ["Day", "Morning", "Afternoon", "Night", "Rotating", "Flexible"]

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

    // Avatar
    private let avatarContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 36
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarGradient = CAGradientLayer()

    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 28)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 22)
        l.textColor = BrandColors.white
        l.textAlignment = .center
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 14)
        l.textColor = BrandColors.steelBlue
        l.textAlignment = .center
        return l
    }()

    private let chipsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()

    // Health Metrics Card
    private let healthCard: UIView = makeCard()
    private let heightRow    = makeInfoRow(icon: "📏", label: "Height")
    private let weightRow    = makeInfoRow(icon: "⚖️", label: "Weight")
    private let bmiRow       = makeInfoRow(icon: "📊", label: "BMI")
    private let bloodRow     = makeInfoRow(icon: "🩸", label: "Blood Group")

    // Shift card
    private let shiftCard: UIView = makeCard()
    private lazy var shiftPicker: UIPickerView = {
        let pv = UIPickerView()
        pv.dataSource = self
        pv.delegate = self
        return pv
    }()

    // Notifications card
    private let notifCard: UIView = makeCard()

    // Buttons
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Changes", for: .normal)
        btn.titleLabel?.font = BrandFonts.heading(size: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = BrandColors.accentBlue
        btn.layer.cornerRadius = 14
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        return btn
    }()

    private lazy var uploadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Upload Document", for: .normal)
        btn.titleLabel?.font = BrandFonts.label(size: 15)
        btn.setTitleColor(BrandColors.accentBlue, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = BrandColors.accentBlue.cgColor
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        btn.addTarget(self, action: #selector(uploadDocument), for: .touchUpInside)
        return btn
    }()

    private lazy var signOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Out", for: .normal)
        btn.titleLabel?.font = BrandFonts.label(size: 15)
        btn.setTitleColor(BrandColors.errorRed, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = BrandColors.errorRed.cgColor
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        btn.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = BrandColors.accentBlue
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = BrandColors.deepNavy
        setupLayout()
        loadProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarGradient.frame = avatarView.bounds
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

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])

        // Avatar section
        setupAvatarSection()
        let avatarStack = UIStackView(arrangedSubviews: [avatarContainer, nameLabel, emailLabel, chipsStack])
        avatarStack.axis = .vertical
        avatarStack.alignment = .center
        avatarStack.spacing = 8
        contentStack.addArrangedSubview(avatarStack)

        // Health Metrics
        buildHealthCard()
        contentStack.addArrangedSubview(healthCard)

        // Shift Settings
        buildShiftCard()
        contentStack.addArrangedSubview(shiftCard)

        // Notifications
        buildNotifCard()
        contentStack.addArrangedSubview(notifCard)

        // Buttons
        contentStack.addArrangedSubview(uploadButton)
        contentStack.addArrangedSubview(saveButton)
        contentStack.addArrangedSubview(signOutButton)
    }

    private func setupAvatarSection() {
        avatarGradient.colors = [BrandColors.accentBlue.cgColor, BrandColors.accentBlue2.cgColor]
        avatarGradient.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient.endPoint = CGPoint(x: 1, y: 1)
        avatarView.layer.insertSublayer(avatarGradient, at: 0)
        avatarView.addSubview(initialsLabel)

        avatarContainer.addSubview(avatarView)
        NSLayoutConstraint.activate([
            avatarView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 72),
            avatarView.heightAnchor.constraint(equalToConstant: 72),
            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
    }

    private func buildHealthCard() {
        let title = makeCardTitle("Health Metrics")
        let rows = UIStackView(arrangedSubviews: [title, heightRow, weightRow, bmiRow, bloodRow])
        rows.axis = .vertical
        rows.spacing = 12
        rows.translatesAutoresizingMaskIntoConstraints = false
        healthCard.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo: healthCard.topAnchor, constant: 16),
            rows.leadingAnchor.constraint(equalTo: healthCard.leadingAnchor, constant: 16),
            rows.trailingAnchor.constraint(equalTo: healthCard.trailingAnchor, constant: -16),
            rows.bottomAnchor.constraint(equalTo: healthCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildShiftCard() {
        let title = makeCardTitle("Shift Settings")
        shiftPicker.translatesAutoresizingMaskIntoConstraints = false
        shiftPicker.heightAnchor.constraint(equalToConstant: 120).isActive = true

        let stack = UIStackView(arrangedSubviews: [title, shiftPicker])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        shiftCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: shiftCard.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: shiftCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: shiftCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: shiftCard.bottomAnchor, constant: -16)
        ])
    }

    private func buildNotifCard() {
        let title = makeCardTitle("Notifications")
        let reminderTypes = ["Daily Reminder", "Streak Alert", "Challenge Update", "Weekly Summary"]
        let stack = UIStackView(arrangedSubviews: [title])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (i, type) in reminderTypes.enumerated() {
            let row = makeSwitchRow(label: type, isOn: true, tag: i)
            stack.addArrangedSubview(row)
        }

        notifCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: notifCard.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: notifCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: notifCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: notifCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Data

    private func loadProfile() {
        guard let userId = SessionManager.shared.userId else { return }
        loadingIndicator.startAnimating()
        Task {
            do {
                let p = try await SupabaseService.shared.fetchParticipant(authUserId: userId)
                self.participant = p

                if let pid = p.id {
                    self.reminders = (try? await SupabaseService.shared.getReminders(participantId: pid)) ?? []
                }

                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.populateUI()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    private func populateUI() {
        guard let p = participant else { return }

        initialsLabel.text = p.displayInitials
        nameLabel.text = p.displayName
        emailLabel.text = p.email

        // Chips
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let chipData = [p.department, p.status, ShiftAwareUtils.formatShiftType(p.shiftType)].compactMap { $0 }
        chipData.forEach { text in
            let chip = makeChip(text: text)
            chipsStack.addArrangedSubview(chip)
        }

        // Health metrics
        updateInfoRow(heightRow, value: p.heightCm.map { "\($0) cm" } ?? "--")
        updateInfoRow(weightRow, value: p.weightKg.map { "\($0) kg" } ?? "--")
        updateInfoRow(bmiRow, value: p.bmi.map { String(format: "%.1f (\(p.bmiCategory))", $0) } ?? "--")
        updateInfoRow(bloodRow, value: p.bloodGroup ?? "--")

        // Shift picker
        selectedShiftType = p.shiftType
        if let idx = shiftTypes.firstIndex(where: { $0.lowercased() == p.shiftType.lowercased() }) {
            shiftPicker.selectRow(idx, inComponent: 0, animated: false)
        }
    }

    // MARK: - Actions

    @objc private func saveChanges() {
        guard var p = participant else { return }
        p.shiftType = selectedShiftType
        loadingIndicator.startAnimating()
        Task {
            do {
                try await SupabaseService.shared.updateParticipant(p)
                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.participant = p
                    let alert = UIAlertController(title: "Saved", message: "Profile updated successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func uploadDocument() {
        let alert = UIAlertController(title: "Upload Document", message: "Document upload feature coming soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func signOut() {
        let confirm = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            Task {
                let vm = AuthViewModel()
                await vm.logout()
                await MainActor.run {
                    guard let window = self?.view.window else { return }
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = LoginViewController()
                    }, completion: nil)
                }
            }
        })
        present(confirm, animated: true)
    }

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        loadProfile()
        sender.endRefreshing()
    }

    // MARK: - Helpers

    private static func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = BrandColors.navyCard
        v.layer.cornerRadius = 16
        return v
    }

    private func makeCardTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = BrandFonts.heading(size: 15)
        l.textColor = BrandColors.white
        return l
    }

    private static func makeInfoRow(icon: String, label: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing

        let iconLabel = UILabel()
        iconLabel.text = "\(icon) \(label)"
        iconLabel.font = BrandFonts.body(size: 14)
        iconLabel.textColor = BrandColors.steelBlue

        let valueLabel = UILabel()
        valueLabel.font = BrandFonts.label(size: 14)
        valueLabel.textColor = BrandColors.white
        valueLabel.tag = 100

        row.addArrangedSubview(iconLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    private func updateInfoRow(_ row: UIView, value: String) {
        (row.viewWithTag(100) as? UILabel)?.text = value
    }

    private func makeChip(text: String) -> UILabel {
        let l = UILabel()
        l.text = "  \(text)  "
        l.font = BrandFonts.body(size: 12)
        l.textColor = BrandColors.steelBlue
        l.backgroundColor = BrandColors.mutedBlue.withAlphaComponent(0.2)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }

    private func makeSwitchRow(label: String, isOn: Bool, tag: Int) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.alignment = .center

        let lbl = UILabel()
        lbl.text = label
        lbl.font = BrandFonts.body(size: 14)
        lbl.textColor = BrandColors.steelBlue

        let sw = UISwitch()
        sw.isOn = isOn
        sw.onTintColor = BrandColors.accentBlue
        sw.tag = tag
        sw.addTarget(self, action: #selector(reminderSwitchChanged(_:)), for: .valueChanged)

        row.addArrangedSubview(lbl)
        row.addArrangedSubview(sw)
        return row
    }

    @objc private func reminderSwitchChanged(_ sender: UISwitch) {
        guard sender.tag < reminders.count else { return }
        var reminder = reminders[sender.tag]
        reminder.isEnabled = sender.isOn
        Task {
            try? await SupabaseService.shared.updateReminder(reminder)
        }
    }
}

// MARK: - UIPickerViewDataSource & Delegate

extension ProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        shiftTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: shiftTypes[row], attributes: [.foregroundColor: BrandColors.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedShiftType = shiftTypes[row]
    }
}
