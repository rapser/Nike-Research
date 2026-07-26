import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applyGlobalAppearance()
        configureNetworking()
        return true
    }

    /// La ventana y el `AppCoordinator` ya no se crean aquí: con el ciclo de vida de
    /// `UIScene` los posee el `SceneDelegate`. Aquí solo queda la configuración que es
    /// del proceso entero y no de una ventana concreta.
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// `.label` en vez de `.black`: en modo oscuro un tint negro dejaba los íconos del
    /// tab bar y los botones de navegación invisibles sobre la barra oscura.
    private func applyGlobalAppearance() {
        UITabBar.appearance().tintColor = .label
        UINavigationBar.appearance().tintColor = .label
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
