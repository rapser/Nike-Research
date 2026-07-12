import Foundation

/// Backed by `GET/POST/DELETE /favorites` — previously pure in-memory, which
/// meant favorites disappeared every time the app was relaunched. Same cached-
/// property + multicast-observer shape as `CartService`.
final class FavoritesService {
    static let shared = FavoritesService()
    private init() {}

    private(set) var favorites: [Shoe] = []

    private var updateObservers: [() -> Void] = []
    func onFavoritesUpdate(_ observer: @escaping () -> Void) {
        updateObservers.append(observer)
    }
    private func notifyUpdated() {
        updateObservers.forEach { $0() }
    }

    func fetchFavorites(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.favorites, decode: [ProductDTO].self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    func add(shoe: Shoe, completion: ((Error?) -> Void)? = nil) {
        let body = AddFavoriteRequestDTO(productId: shoe.uid)
        APIClient.shared.request(.addFavorite, body: body, decode: [ProductDTO].self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    func remove(shoe: Shoe, completion: ((Error?) -> Void)? = nil) {
        APIClient.shared.request(.removeFavorite(productId: shoe.uid), decode: [ProductDTO].self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// Toggle is the common case (heart button) — looks at the local cache to
    /// decide which network call to make, so callers don't need to know the
    /// current state themselves.
    func toggle(_ shoe: Shoe, completion: ((Error?) -> Void)? = nil) {
        if isFavorite(shoe) {
            remove(shoe: shoe, completion: completion)
        } else {
            add(shoe: shoe, completion: completion)
        }
    }

    func isFavorite(_ shoe: Shoe) -> Bool {
        favorites.contains(where: { $0.uid == shoe.uid })
    }

    /// Local-only reset, no network call — used on logout so the cache doesn't
    /// leak the signed-out account's favorites to whoever logs in next.
    func clearAll() {
        favorites = []
        notifyUpdated()
    }

    private func handle(_ result: Result<[ProductDTO], APIError>, completion: ((Error?) -> Void)?) {
        switch result {
        case .success(let dtos):
            favorites = dtos.map(ProductsService.toShoe)
            notifyUpdated()
            completion?(nil)
        case .failure(let error):
            completion?(error)
        }
    }
}
