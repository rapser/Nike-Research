import UIKit

final class FavoritesViewModel {
    var onFavoritesChanged: (() -> Void)?

    init() {
        FavoritesService.shared.onFavoritesUpdated = { [weak self] in
            self?.onFavoritesChanged?()
        }
    }

    var title: String { "FAVORITES" }
    var favorites: [Shoe] { FavoritesService.shared.favorites }
    var count: Int { FavoritesService.shared.favorites.count }
    var isEmpty: Bool { FavoritesService.shared.favorites.isEmpty }

    func shoe(at index: Int) -> Shoe { favorites[index] }
    func removeFromFavorites(at index: Int) {
        let shoe = favorites[index]
        FavoritesService.shared.toggle(shoe)
    }
}
