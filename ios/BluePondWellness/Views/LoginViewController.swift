// LoginViewController.swift
// BluePond Wellness

import UIKit
import Combine

final class LoginViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = AuthViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .onDrag
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "AppLogo")
        iv.tintColor = BrandColors.white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BluePond Wellness"
        label.font = BrandFonts.heading(size: 26)
        label.textColor = BrandColors.white
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to your account"
        label.font = BrandFonts.body(size: 14)
        label.textColor = BrandColors.steelBlue
        label.textAlignment = .center
        return label
    }()

    private lazy var emailTextField: UITextField = {
        let tf = makeTextField(placeholder: "Email Address", keyboardType: .emailAddress)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()

    private lazy var passwordTextField: UITextField = {
        let tf = makeTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        tf.rightView = passwordToggleButton
        tf.rightViewMode = .always
        return tf
    }()

    private lazy var passwordToggleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        btn.tintColor = BrandColors.steelBlue
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return btn
    }()

    private lazy var signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = BrandFonts.heading(size: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = BrandColors.accentBlue
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        btn.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(BrandColors.accentBlue, for: .normal)
        btn.titleLabel?.font = BrandFonts.body(size: 14)
        btn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return btn
    }()

    private let loadingOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrandColors.deepNavy
        setupLayout()
        bindViewModel()
        setupKeyboardDismissal()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 48),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])

        // Logo container
        let logoContainer = UIView()
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainer.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainer.bottomAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        contentStack.addArrangedSubview(logoContainer)
        contentStack.setCustomSpacing(24, after: logoContainer)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.setCustomSpacing(32, after: subtitleLabel)
        contentStack.addArrangedSubview(emailTextField)
        contentStack.addArrangedSubview(passwordTextField)
        contentStack.setCustomSpacing(24, after: passwordTextField)
        contentStack.addArrangedSubview(signInButton)
        contentStack.addArrangedSubview(forgotPasswordButton)

        // Loading overlay
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.setLoadingState(loading)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showError(message)
            }
            .store(in: &cancellables)

        viewModel.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.navigateToMain()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func signInTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        Task {
            await viewModel.login(email: email, password: password)
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordToggleButton.isSelected.toggle()
        passwordTextField.isSecureTextEntry = !passwordToggleButton.isSelected
    }

    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(
            title: "Forgot Password",
            message: "Please contact your HR or Wellness Coordinator to reset your password.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - State

    private func setLoadingState(_ loading: Bool) {
        loadingOverlay.isHidden = !loading
        if loading {
            loadingIndicator.startAnimating()
            signInButton.isEnabled = false
            signInButton.alpha = 0.6
        } else {
            loadingIndicator.stopAnimating()
            signInButton.isEnabled = true
            signInButton.alpha = 1.0
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Sign In Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func navigateToMain() {
        guard let window = view.window else { return }
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
            window.rootViewController = MainTabBarController()
        }, completion: nil)
    }

    // MARK: - Keyboard

    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Helpers

    private func makeTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: BrandColors.steelBlue]
        )
        tf.keyboardType = keyboardType
        tf.font = BrandFonts.body(size: 16)
        tf.textColor = BrandColors.white
        tf.backgroundColor = BrandColors.navyCard
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = BrandColors.mutedBlue.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 52).isActive = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}
