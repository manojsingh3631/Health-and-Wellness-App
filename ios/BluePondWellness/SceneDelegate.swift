import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = BrandColors.bgPrimary

        let rootVC = resolveRootViewController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }

    // MARK: – Root resolution

    private func resolveRootViewController() -> UIViewController {
        let session = SessionManager.shared

        if !session.isLoggedIn {
            return UINavigationController(rootViewController: LoginViewController())
        }

        if !session.hasSeenOnboarding {
            return UINavigationController(rootViewController: OnboardingViewController())
        }

        return MainTabBarController()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
