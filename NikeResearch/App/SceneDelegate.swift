import UIKit

/// Dueño de la ventana y del `AppCoordinator`, que antes vivían en el `AppDelegate`.
///
/// Con el ciclo de vida de `UIScene` es la escena —no la aplicación— la que posee una
/// ventana: una app puede tener varias escenas a la vez (Split View en iPad, varias
/// ventanas en Mac), cada una con su propia jerarquía de vistas. Por eso el coordinador
/// raíz se crea aquí, una vez por escena, y no una sola vez por proceso.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // `UIWindow(windowScene:)` en vez de `UIWindow(frame: UIScreen.main.bounds)`:
        // la ventana toma su tamaño de la escena, que es lo correcto cuando no ocupa
        // la pantalla entera.
        let win = UIWindow(windowScene: windowScene)
        window = win

        // Antes de mostrar nada, para que la app no arranque en el modo del sistema y
        // salte al elegido por el usuario un instante después.
        win.overrideUserInterfaceStyle = AppearanceService.shared.mode.userInterfaceStyle

        let coordinator = AppCoordinator(window: win)
        appCoordinator = coordinator
        coordinator.start()

        win.makeKeyAndVisible()
    }
}
