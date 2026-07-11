import UIKit

final class ShoeDetailViewModel {
    let shoe: Shoe
    var onAddToCart: ((Shoe) -> Void)?
    var onFavoriteToggled: (() -> Void)?

    init(shoe: Shoe) { self.shoe = shoe }

    var title: String { shoe.name }
    var name: String { shoe.name }
    var description: String { shoe.description }
    var detail: String { shoe.detail }
    var buyButtonTitle: String { "BUY  \(shoe.formattedPrice)" }
    var images: [UIImage] { shoe.images }
    var suggestions: [Shoe] { Shoe.fetchShoes() }
    var suggestionCount: Int { suggestions.count }

    var isFavorite: Bool { FavoritesService.shared.isFavorite(shoe) }

    func suggestionImage(at index: Int) -> UIImage? { suggestions[index].images.first }
    func suggestionName(at index: Int) -> String { suggestions[index].name }
    func suggestionPrice(at index: Int) -> String { suggestions[index].formattedPrice }

    func addToCartTapped() {
        onAddToCart?(shoe)
    }

    func toggleFavorite() {
        FavoritesService.shared.toggle(shoe)
        onFavoriteToggled?()
    }
}
