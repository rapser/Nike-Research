import UIKit

final class NikePlusViewModel {
    var onActivitiesChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        NikePlusService.shared.onActivitiesUpdated = { [weak self] in
            self?.onActivitiesChanged?()
        }
    }

    var title: String { String(localized: "NIKE+") }
    var memberName: String { AuthService.shared.currentUser?.name ?? String(localized: "Guest") }
    var memberSince: String { AuthService.shared.currentUser?.memberSince ?? "" }
    /// El backend no expone foto de perfil, y la que se usaba antes era una foto del
    /// catálogo empaquetada en el bundle (el asset `s1`), que dejó de existir cuando el
    /// catálogo pasó a servirse por URL. La celda pone su propio placeholder.
    var avatarImage: UIImage? { nil }
    var activityCount: Int { NikePlusService.shared.activities.count }

    /// Sin sesión no hay perfil ni actividad que mostrar, así que la pantalla se reduce
    /// a una invitación a iniciar sesión en vez de una ficha con datos vacíos.
    var isSignedOut: Bool { state == .signedOut }
    var signedOutTitle: String { String(localized: "SIGN IN TO SEE YOUR ACTIVITY") }
    var signedOutMessage: String { String(localized: "Log in to track your runs and progress.") }

    func loadActivities(completion: @escaping (Error?) -> Void) {
        // Sin sesión no se llama a la API: esta pantalla vive detrás de una ruta
        // protegida y la petición solo devolvería un 401.
        guard AuthService.shared.isAuthenticated else {
            state = .signedOut
            completion(nil)
            return
        }
        state = .loading
        NikePlusService.shared.fetchActivities { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.activityCount == 0 ? .empty : .loaded)
            completion(error)
        }
    }

    func activityTitle(at index: Int) -> String { NikePlusService.shared.activities[index].title }
    func activityValue(at index: Int) -> String { NikePlusService.shared.activities[index].value }
    func activityUnit(at index: Int) -> String { NikePlusService.shared.activities[index].unit }
}
