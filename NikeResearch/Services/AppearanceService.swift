import UIKit

enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light:  .light
        case .dark:   .dark
        }
    }

    var title: String {
        switch self {
        case .system: String(localized: "Automatic")
        case .light:  String(localized: "Light")
        case .dark:   String(localized: "Dark")
        }
    }

    var sfSymbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon"
        }
    }
}

/// Preferencia de apariencia elegida por el usuario, persistida en `UserDefaults`.
///
/// A diferencia del resto de servicios, este no habla con la API: es un ajuste del
/// dispositivo, no de la cuenta, así que sobrevive al logout y no se sincroniza entre
/// dispositivos. Por eso tampoco lo limpia `ProfileCoordinator` al cerrar sesión.
final class AppearanceService {
    static let shared = AppearanceService()
    private init() {}

    private let storageKey = "appearanceMode"

    var mode: AppearanceMode {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? ""
        return AppearanceMode(rawValue: raw) ?? .system
    }

    func setMode(_ mode: AppearanceMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: storageKey)
        apply(animated: true)
    }

    /// `.unspecified` devuelve el control al ajuste del sistema, que es justo lo que
    /// debe pasar con el modo automático.
    func apply(animated: Bool = false) {
        let style = mode.userInterfaceStyle
        for window in Self.activeWindows {
            guard animated else {
                window.overrideUserInterfaceStyle = style
                continue
            }
            // Sin esto el cambio es un corte seco de una paleta a la otra.
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
                window.overrideUserInterfaceStyle = style
            }
        }
    }

    private static var activeWindows: [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
}
