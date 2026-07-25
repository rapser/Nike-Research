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

    func loadFavorites(completion: @escaping (Error?) -> Void) {
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
