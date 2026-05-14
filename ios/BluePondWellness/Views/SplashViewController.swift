// SplashViewController.swift
// BluePond Wellness

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - UI Components

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "AppLogo")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "BluePond Wellness"
        label.font = BrandFonts.heading(size: 28)
        label.textColor = BrandColors.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Daily Health Companion"
        label.font = BrandFonts.body(size: 14)
        label.textColor = BrandColors.steelBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let poweredByLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered by BluePond AI"
        label.font = BrandFonts.body(size: 12)
        label.textColor = BrandColors.mutedBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrandColors.deepNavy
        setupLayout()
        startSplashTimer()
    }

    // MARK: - Layout

    private func setupLayout() {
        stackView.addArrangedSubview(logoImageView)
        stackView.setCustomSpacing(20, after: logoImageView)
        stackView.addArrangedSubview(appNameLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.setCustomSpacing(24, after: subtitleLabel)
        stackView.addArrangedSubview(poweredByLabel)
        stackView.setCustomSpacing(32, after: poweredByLabel)
        stackView.addArrangedSubview(activityIndicator)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])

        activityIndicator.startAnimating()
    }

    // MARK: - Timer

    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.navigateToNextScreen()
        }
    }

    private func navigateToNextScreen() {
        let destination: UIViewController
        if SessionManager.shared.isLoggedIn {
            destination = MainTabBarController()
        } else {
            destination = LoginViewController()
        }

        let window = view.window
        UIView.transition(with: window!, duration: 0.4, options: .transitionCrossDissolve, animations: {
            window?.rootViewController = destination
        }, completion: nil)
    }
}
