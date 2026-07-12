import UIKit

final class FavoritesViewModel {
    var onFavoritesChanged: (() -> Void)?

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
        FavoritesService.shared.fetchFavorites(completion: completion)
    }

    func shoe(at index: Int) -> Shoe { favorites[index] }

    func removeFromFavorites(at index: Int, completion: ((Error?) -> Void)? = nil) {
        let shoe = favorites[index]
        FavoritesService.shared.remove(shoe: shoe, completion: completion)
    }
}
