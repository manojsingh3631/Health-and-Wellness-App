import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ── Appearance ──────────────────────────────────────────────────────────
        applyGlobalAppearance()

        // ── Push notifications authorisation (deferred to first login) ──────────
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    // MARK: – Private

    private func applyGlobalAppearance() {
        // Navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor     = BrandColors.bgPrimary
        navBarAppearance.titleTextAttributes = [.foregroundColor: BrandColors.textPrimary]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: BrandColors.textPrimary]
        UINavigationBar.appearance().standardAppearance   = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor            = BrandColors.accentBlue

        // Tab bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = BrandColors.bgPrimary
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor     = BrandColors.accentBlue
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: BrandColors.accentBlue]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor       = BrandColors.textSecondary
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes  = [.foregroundColor: BrandColors.textSecondary]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        // Global tint
        UIView.appearance(whenContainedInInstancesOf: [UIWindow.self]).tintColor = BrandColors.accentBlue
    }
}
