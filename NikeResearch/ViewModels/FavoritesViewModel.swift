import UIKit

final class FavoritesViewModel {
    var onFavoritesChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        FavoritesService.shared.onFavoritesUpdate { [weak self] in
            self?.onFavoritesChanged?()
        }
    }

    var title: String { String(localized: "FAVORITES") }
    var favorites: [Shoe] { FavoritesService.shared.favorites }
    var count: Int { FavoritesService.shared.favorites.count }
    var isEmpty: Bool { FavoritesService.shared.favorites.isEmpty }

    /// El estado vacío dice cosas distintas según haya sesión o no: un invitado no tiene
    /// una lista vacía, tiene una lista que aún no existe.
    var showsEmptyState: Bool { state == .empty || state == .signedOut }
    var emptySymbol: String { state == .signedOut ? "person.crop.circle" : "heart" }
    var emptyTitle: String {
        state == .signedOut
            ? String(localized: "SIGN IN TO SEE YOUR FAVORITES")
            : String(localized: "NO FAVORITES YET")
    }
    var emptyMessage: String {
        state == .signedOut
            ? String(localized: "Log in to save shoes to your favorites.")
            : String(localized: "Tap the heart on any shoe to save it here.")
    }

    func loadFavorites(completion: @escaping (Error?) -> Void) {
        // Sin sesión no se llama a la API: esta pantalla vive detrás de una ruta
        // protegida y la petición solo devolvería un 401.
        guard AuthService.shared.isAuthenticated else {
            state = .signedOut
            completion(nil)
            return
        }
        state = .loading
        FavoritesService.shared.fetchFavorites { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.isEmpty ? .empty : .loaded)
            completion(error)
        }
    }

    func shoe(at index: Int) -> Shoe { favorites[index] }

    func removeFromFavorites(at index: Int, completion: ((Error?) -> Void)? = nil) {
        let shoe = favorites[index]
        FavoritesService.shared.remove(shoe: shoe, completion: completion)
    }
}
