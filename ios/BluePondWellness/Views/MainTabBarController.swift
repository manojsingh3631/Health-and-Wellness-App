// MainTabBarController.swift
// BluePond Wellness

import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        applyBranding()
    }

    // MARK: - Setup Tabs

    private func setupTabs() {
        let homeVC    = makeNav(root: HomeViewController(),       title: "Home",        image: "house.fill",         tag: 0)
        let logVC     = makeNav(root: LogViewController(),        title: "Log",         image: "plus.circle.fill",   tag: 1)
        let progressVC = makeNav(root: ProgressViewController(),  title: "Progress",    image: "chart.xyaxis.line",  tag: 2)
        let leaderVC  = makeNav(root: LeaderboardViewController(), title: "Leaderboard", image: "chart.bar.fill",   tag: 3)
        let profileVC = makeNav(root: ProfileViewController(),    title: "Profile",     image: "person.fill",        tag: 4)

        viewControllers = [homeVC, logVC, progressVC, leaderVC, profileVC]
    }

    private func makeNav(root: UIViewController, title: String, image: String, tag: Int) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            tag: tag
        )
        nav.navigationBar.barTintColor = BrandColors.deepNavy
        nav.navigationBar.tintColor = BrandColors.accentBlue
        nav.navigationBar.titleTextAttributes = [
            .foregroundColor: BrandColors.white,
            .font: BrandFonts.heading(size: 17)
        ]
        nav.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: BrandColors.white,
            .font: BrandFonts.heading(size: 32)
        ]
        nav.navigationBar.prefersLargeTitles = false
        nav.navigationBar.isTranslucent = false

        // iOS 15+ appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = BrandColors.deepNavy
            appearance.titleTextAttributes = [
                .foregroundColor: BrandColors.white,
                .font: BrandFonts.heading(size: 17)
            ]
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
        }

        return nav
    }

    // MARK: - Branding

    private func applyBranding() {
        tabBar.barTintColor = BrandColors.deepNavy
        tabBar.tintColor = BrandColors.accentBlue
        tabBar.unselectedItemTintColor = BrandColors.mutedBlue
        tabBar.isTranslucent = false

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = BrandColors.deepNavy

            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = BrandColors.mutedBlue
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: BrandColors.mutedBlue]
            itemAppearance.selected.iconColor = BrandColors.accentBlue
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: BrandColors.accentBlue]

            appearance.stackedLayoutAppearance = itemAppearance
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
