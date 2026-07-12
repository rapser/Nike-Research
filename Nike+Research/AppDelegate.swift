import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applyGlobalAppearance()
        configureNetworking()

        let win = UIWindow(frame: UIScreen.main.bounds)
        window = win

        let coordinator = AppCoordinator(window: win)
        appCoordinator = coordinator
        coordinator.start()

        win.makeKeyAndVisible()
        return true
    }

    private func applyGlobalAppearance() {
        UITabBar.appearance().tintColor = .black
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().isTranslucent = false
    }

    /// Forces `AppConfig.baseURL` to resolve (fails fast on a missing/malformed
    /// plist) and wires up the token-refresh-failed callback.
    private func configureNetworking() {
        _ = AppConfig.baseURL
        AuthTokenInterceptor.shared.onSessionExpired = {
            AuthService.shared.logout()
        }
    }
}
