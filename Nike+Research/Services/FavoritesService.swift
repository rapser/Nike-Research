final class FavoritesService {
    static let shared = FavoritesService()
    private init() {}

    private(set) var favorites: [Shoe] = []
    var onFavoritesUpdated: (() -> Void)?

    func toggle(_ shoe: Shoe) {
        if let idx = favorites.firstIndex(where: { $0.uid == shoe.uid }) {
            favorites.remove(at: idx)
        } else {
            favorites.append(shoe)
        }
        onFavoritesUpdated?()
    }

    func isFavorite(_ shoe: Shoe) -> Bool {
        favorites.contains(where: { $0.uid == shoe.uid })
    }
}
