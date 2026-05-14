// LogViewController.swift
// BluePond Wellness

import UIKit

// MARK: - ActivityInputCell

final class ActivityInputCell: UITableViewCell {

    static let reuseIdentifier = "ActivityInputCell"

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let activityNameLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.font = BrandFonts.heading(size: 28)
        tf.textColor = BrandColors.white
        tf.textAlignment = .right
        tf.keyboardType = .decimalPad
        tf.backgroundColor = .clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let unitLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.body(size: 13)
        l.textColor = BrandColors.steelBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = BrandColors.accentBlue
        pv.trackTintColor = BrandColors.mutedBlue.withAlphaComponent(0.3)
        pv.layer.cornerRadius = 2
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = BrandColors.navyCard
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(activityNameLabel)
        contentView.addSubview(inputTextField)
        contentView.addSubview(unitLabel)
        contentView.addSubview(progressView)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 36),

            activityNameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            activityNameLabel.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),

            unitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unitLabel.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),

            inputTextField.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor, constant: -8),
            inputTextField.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            inputTextField.widthAnchor.constraint(equalToConstant: 100),

            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    func configure(emoji: String, name: String, unit: String, value: String, progress: Float) {
        emojiLabel.text = emoji
        activityNameLabel.text = name
        unitLabel.text = unit
        inputTextField.text = value
        progressView.progress = progress
    }
}

// MARK: - SugarFreeCell

final class SugarFreeCell: UITableViewCell {

    static let reuseIdentifier = "SugarFreeCell"

    var onToggle: ((Bool) -> Void)?
    private(set) var isYes: Bool = false

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.text = "🍎"
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "No Added Sugar"
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var yesButton: UIButton = buildToggleButton(title: "Yes", tag: 1)
    private lazy var noButton: UIButton  = buildToggleButton(title: "No",  tag: 0)

    private func buildToggleButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = BrandFonts.label(size: 14)
        btn.setTitleColor(BrandColors.steelBlue, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = BrandColors.mutedBlue.cgColor
        btn.backgroundColor = .clear
        btn.widthAnchor.constraint(equalToConstant: 64).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.tag = tag
        btn.addTarget(self, action: #selector(toggleTapped(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = BrandColors.navyCard
        selectionStyle = .none
        setupLayout()
        setSelection(isYes: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        let btnStack = UIStackView(arrangedSubviews: [yesButton, noButton])
        btnStack.axis = .horizontal
        btnStack.spacing = 8
        btnStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(btnStack)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            btnStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            btnStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configure(value: Bool) {
        isYes = value
        setSelection(isYes: value)
    }

    private func setSelection(isYes: Bool) {
        yesButton.backgroundColor = isYes ? BrandColors.teal.withAlphaComponent(0.2) : .clear
        yesButton.setTitleColor(isYes ? BrandColors.teal : BrandColors.steelBlue, for: .normal)
        yesButton.layer.borderColor = isYes ? BrandColors.teal.cgColor : BrandColors.mutedBlue.cgColor

        noButton.backgroundColor = !isYes ? BrandColors.errorRed.withAlphaComponent(0.15) : .clear
        noButton.setTitleColor(!isYes ? BrandColors.errorRed : BrandColors.steelBlue, for: .normal)
        noButton.layer.borderColor = !isYes ? BrandColors.errorRed.cgColor : BrandColors.mutedBlue.cgColor
    }

    @objc private func toggleTapped(_ sender: UIButton) {
        isYes = sender.tag == 1
        setSelection(isYes: isYes)
        onToggle?(isYes)
    }
}

// MARK: - EstimatedPointsCell

final class EstimatedPointsCell: UITableViewCell {

    static let reuseIdentifier = "EstimatedPointsCell"

    private let descLabel: UILabel = {
        let l = UILabel()
        l.text = "Estimated Points"
        l.font = BrandFonts.label(size: 14)
        l.textColor = BrandColors.steelBlue
        return l
    }()

    let pointsLabel: UILabel = {
        let l = UILabel()
        l.font = BrandFonts.heading(size: 28)
        l.textColor = BrandColors.teal
        l.textAlignment = .right
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = BrandColors.navyCard
        selectionStyle = .none

        let sv = UIStackView(arrangedSubviews: [descLabel, pointsLabel])
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sv)

        NSLayoutConstraint.activate([
            sv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sv.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            sv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(points: Double) {
        pointsLabel.text = String(format: "%.1f pts", points)
    }
}

// MARK: - SubmitCell

final class SubmitCell: UITableViewCell {

    static let reuseIdentifier = "SubmitCell"

    let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit Activity", for: .normal)
        btn.titleLabel?.font = BrandFonts.heading(size: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = BrandColors.accentBlue
        btn.layer.cornerRadius = 14
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - LogViewController

final class LogViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = LogViewModel()

    // MARK: - State

    private var steps: Int = 0
    private var water: Double = 0
    private var yoga: Int = 0
    private var workout: Int = 0
    private var sugarFree: Bool = false

    // MARK: - Row indexes

    private enum Row: Int, CaseIterable {
        case steps = 0, water, yoga, workout, sugarFree, estimatedPoints, submit
    }

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = BrandColors.deepNavy
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ActivityInputCell.self, forCellReuseIdentifier: ActivityInputCell.reuseIdentifier)
        tv.register(SugarFreeCell.self, forCellReuseIdentifier: SugarFreeCell.reuseIdentifier)
        tv.register(EstimatedPointsCell.self, forCellReuseIdentifier: EstimatedPointsCell.reuseIdentifier)
        tv.register(SubmitCell.self, forCellReuseIdentifier: SubmitCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        return tv
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
        title = "Log Activity"
        view.backgroundColor = BrandColors.deepNavy
        viewModel.delegate = self
        setupLayout()
        loadData()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadData() {
        loadingIndicator.startAnimating()
        Task {
            await viewModel.loadData()
        }
    }

    private func prefillExistingLog() {
        if let log = viewModel.existingLog {
            steps    = log.stepsCount
            water    = log.waterIntakeLiters
            yoga     = log.yogaMinutes
            workout  = log.workoutMinutes
            sugarFree = log.noAddedSugarDay
        }
        tableView.reloadData()
    }

    private func updateEstimatedPoints() {
        let pts = viewModel.calculateEstimatedPoints(
            steps: steps, water: water, yoga: yoga,
            workout: workout, sugarFree: sugarFree
        )
        if let cell = tableView.cellForRow(at: IndexPath(row: Row.estimatedPoints.rawValue, section: 0)) as? EstimatedPointsCell {
            cell.configure(points: pts)
        }
    }

    private func submit() {
        let isUpdate = viewModel.existingLog != nil
        loadingIndicator.startAnimating()

        Task {
            let result: Result<ActivityLog, Error>
            if isUpdate {
                result = await viewModel.updateLog(steps: steps, water: water, yoga: yoga, workout: workout, sugarFree: sugarFree)
            } else {
                result = await viewModel.submitLog(steps: steps, water: water, yoga: yoga, workout: workout, sugarFree: sugarFree)
            }

            await MainActor.run { [weak self] in
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let log):
                    let pts = log.pointsEarned
                    let alert = UIAlertController(
                        title: "Activity Logged",
                        message: String(format: "You earned %.1f points today!", pts),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Great!", style: .default) { _ in
                        self?.tabBarController?.selectedIndex = 0
                    })
                    self?.present(alert, animated: true)

                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension LogViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }

        switch row {
        case .steps:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActivityInputCell.reuseIdentifier, for: indexPath) as! ActivityInputCell
            let maxSteps = 15000.0
            cell.configure(emoji: "👟", name: "Steps", unit: "steps",
                           value: steps > 0 ? "\(steps)" : "",
                           progress: Float(min(Double(steps) / maxSteps, 1.0)))
            cell.inputTextField.tag = row.rawValue
            cell.inputTextField.delegate = self
            return cell

        case .water:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActivityInputCell.reuseIdentifier, for: indexPath) as! ActivityInputCell
            cell.configure(emoji: "💧", name: "Water", unit: "L",
                           value: water > 0 ? String(format: "%.1f", water) : "",
                           progress: Float(min(water / 3.5, 1.0)))
            cell.inputTextField.tag = row.rawValue
            cell.inputTextField.delegate = self
            return cell

        case .yoga:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActivityInputCell.reuseIdentifier, for: indexPath) as! ActivityInputCell
            cell.configure(emoji: "🧘", name: "Yoga", unit: "min",
                           value: yoga > 0 ? "\(yoga)" : "",
                           progress: Float(min(Double(yoga) / 60.0, 1.0)))
            cell.inputTextField.tag = row.rawValue
            cell.inputTextField.delegate = self
            return cell

        case .workout:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActivityInputCell.reuseIdentifier, for: indexPath) as! ActivityInputCell
            cell.configure(emoji: "🏋️", name: "Workout", unit: "min",
                           value: workout > 0 ? "\(workout)" : "",
                           progress: Float(min(Double(workout) / 90.0, 1.0)))
            cell.inputTextField.tag = row.rawValue
            cell.inputTextField.delegate = self
            return cell

        case .sugarFree:
            let cell = tableView.dequeueReusableCell(withIdentifier: SugarFreeCell.reuseIdentifier, for: indexPath) as! SugarFreeCell
            cell.configure(value: sugarFree)
            cell.onToggle = { [weak self] value in
                self?.sugarFree = value
                self?.updateEstimatedPoints()
            }
            return cell

        case .estimatedPoints:
            let cell = tableView.dequeueReusableCell(withIdentifier: EstimatedPointsCell.reuseIdentifier, for: indexPath) as! EstimatedPointsCell
            cell.configure(points: viewModel.estimatedPoints)
            return cell

        case .submit:
            let cell = tableView.dequeueReusableCell(withIdentifier: SubmitCell.reuseIdentifier, for: indexPath) as! SubmitCell
            let isUpdate = viewModel.existingLog != nil
            let canEdit  = viewModel.existingLog?.canEdit ?? true
            cell.submitButton.setTitle(isUpdate ? "Update Activity" : "Submit Activity", for: .normal)
            cell.submitButton.isEnabled = !isUpdate || canEdit
            cell.submitButton.alpha = (!isUpdate || canEdit) ? 1.0 : 0.5
            cell.submitButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension LogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITextFieldDelegate

extension LogViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        guard let row = Row(rawValue: textField.tag) else { return true }
        switch row {
        case .steps:   steps   = Int(newText) ?? 0
        case .water:   water   = Double(newText) ?? 0
        case .yoga:    yoga    = Int(newText) ?? 0
        case .workout: workout = Int(newText) ?? 0
        default: break
        }
        DispatchQueue.main.async { [weak self] in
            self?.updateEstimatedPoints()
        }
        return true
    }
}

// MARK: - Actions

extension LogViewController {
    @objc private func submitTapped() {
        submit()
    }
}

// MARK: - LogViewModelDelegate

extension LogViewController: LogViewModelDelegate {
    func logViewModelDidLoadData() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.prefillExistingLog()
        }
    }

    func logViewModelDidFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
