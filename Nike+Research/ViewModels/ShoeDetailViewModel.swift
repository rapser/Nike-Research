import UIKit

final class ShoeDetailViewModel {
    let shoe: Shoe
    var onAddToCart: ((Shoe, Int) -> Void)?
    var onFavoriteToggled: (() -> Void)?
    var onQuantityChanged: (() -> Void)?

    private(set) var quantity: Int = 1 {
        didSet { onQuantityChanged?() }
    }

    init(shoe: Shoe) { self.shoe = shoe }

    var title: String { shoe.name }
    var name: String { shoe.name }
    var description: String { shoe.description }
    var detail: String { shoe.detail }
    var quantityText: String { "\(quantity)" }

    var buyButtonTitle: String {
        let total = shoe.price * Double(quantity)
        let totalText = "$\(Int(total))"
        let buyWord = String(localized: "BUY")
        return quantity > 1 ? "\(buyWord) \(quantity)  \(totalText)" : "\(buyWord)  \(totalText)"
    }

    var images: [UIImage] { shoe.images }
    var suggestions: [Shoe] { Shoe.fetchShoes() }
    var suggestionCount: Int { suggestions.count }

    var isFavorite: Bool { FavoritesService.shared.isFavorite(shoe) }

    func suggestionImage(at index: Int) -> UIImage? { suggestions[index].images.first }
    func suggestionName(at index: Int) -> String { suggestions[index].name }
    func suggestionPrice(at index: Int) -> String { suggestions[index].formattedPrice }

    func incrementQuantity() {
        quantity += 1
    }

    func decrementQuantity() {
        guard quantity > 1 else { return }
        quantity -= 1
    }

    func addToCartTapped() {
        onAddToCart?(shoe, quantity)
    }

    func toggleFavorite(completion: @escaping (Error?) -> Void) {
        FavoritesService.shared.toggle(shoe) { [weak self] error in
            if error == nil {
                self?.onFavoriteToggled?()
            }
            completion(error)
        }
    }
}
