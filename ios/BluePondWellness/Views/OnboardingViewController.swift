import UIKit

/// 3-page onboarding shown on first login.
/// Mirrors the Android OnboardingActivity logic.
final class OnboardingViewController: UIViewController {

    // MARK: – Data

    private struct Page {
        let title: String
        let body: String
        let systemImage: String
    }

    private let pages: [Page] = [
        Page(title: "Welcome to BluePond Wellness",
             body: "Participate in your company's wellness challenge, log daily activities, and earn points toward team goals.",
             systemImage: "heart.circle.fill"),
        Page(title: "How Scoring Works",
             body: "Each activity earns points based on your coordinator's scoring rules — steps, water intake, yoga, workouts, and sugar-free days.",
             systemImage: "chart.bar.fill"),
        Page(title: "Shift-Aware Logging",
             body: "Night shift? No problem. Your active day is based on your shift window, not midnight, so your streak stays intact.",
             systemImage: "moon.stars.fill"),
    ]

    // MARK: – UI

    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate   = self
        return vc
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages       = pages.count
        pc.currentPage         = 0
        pc.currentPageIndicatorTintColor = BrandColors.accentBlue
        pc.pageIndicatorTintColor        = BrandColors.textSecondary.withAlphaComponent(0.4)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private lazy var nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title              = "Next"
        config.baseBackgroundColor = BrandColors.accentBlue
        config.baseForegroundColor = .white
        config.cornerStyle        = .large
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(BrandColors.textSecondary, for: .normal)
        btn.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var currentPage = 0

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrandColors.bgPrimary
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupPageVC()
        setupControls()
    }

    private func setupPageVC() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        pageVC.setViewControllers(
            [makePageVC(index: 0)], direction: .forward, animated: false)
    }

    private func setupControls() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -8),

            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -8),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    private func makePageVC(index: Int) -> OnboardingPageViewController {
        let vc = OnboardingPageViewController()
        vc.configure(with: pages[index], index: index)
        return vc
    }

    // MARK: – Actions

    @objc private func nextTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            pageVC.setViewControllers(
                [makePageVC(index: currentPage)], direction: .forward, animated: true)
            pageControl.currentPage = currentPage
            updateButtons()
        } else {
            finishOnboarding()
        }
    }

    @objc private func skipTapped() {
        finishOnboarding()
    }

    private func updateButtons() {
        let isLast = currentPage == pages.count - 1
        nextButton.configuration?.title = isLast ? "Get Started" : "Next"
        skipButton.isHidden = isLast
    }

    private func finishOnboarding() {
        SessionManager.shared.setOnboardingSeen(true)
        let tabBar = MainTabBarController()
        (view.window?.windowScene?.delegate as? SceneDelegate)?.window?.rootViewController = tabBar
    }
}

// MARK: – UIPageViewControllerDataSource / Delegate

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                             viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageViewController,
              vc.pageIndex > 0 else { return nil }
        return makePageVC(index: vc.pageIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                             viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageViewController,
              vc.pageIndex < pages.count - 1 else { return nil }
        return makePageVC(index: vc.pageIndex + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                             didFinishAnimating finished: Bool,
                             previousViewControllers: [UIViewController],
                             transitionCompleted completed: Bool) {
        guard completed,
              let vc = pageViewController.viewControllers?.first as? OnboardingPageViewController
        else { return }
        currentPage = vc.pageIndex
        pageControl.currentPage = currentPage
        updateButtons()
    }
}

// MARK: – Page content VC

final class OnboardingPageViewController: UIViewController {

    var pageIndex = 0

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor   = BrandColors.accentBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = BrandFonts.headlineMedium
        lbl.textColor     = BrandColors.textPrimary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bodyLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = BrandFonts.bodyRegular
        lbl.textColor     = BrandColors.textSecondary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrandColors.bgPrimary

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, bodyLabel])
        stack.axis      = .vertical
        stack.alignment = .center
        stack.spacing   = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 160),
            imageView.heightAnchor.constraint(equalToConstant: 160),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    func configure(with page: (title: String, body: String, systemImage: String), index: Int) {
        pageIndex = index
        titleLabel.text = page.title
        bodyLabel.text  = page.body
        imageView.image = UIImage(systemName: page.systemImage)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 80, weight: .light))
    }
}
