import UIKit

final class ShoeDetailViewModel {
    let shoe: Shoe
    var onAddToCart: ((Shoe, Int, @escaping (Error?) -> Void) -> Void)?
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
        let totalText = CurrencyFormatter.string(from: total)
        let buyWord = String(localized: "BUY")
        return quantity > 1 ? "\(buyWord) \(quantity)  \(totalText)" : "\(buyWord)  \(totalText)"
    }

    var images: [UIImage] { shoe.images }

    /// Antes esto era `Shoe.fetchShoes()`: un catálogo hardcodeado de 2017 que nunca
    /// consultaba la API. Se cachea en vez de recalcularse porque los tres accesores de
    /// abajo se llaman una vez por celda durante el scroll.
    private(set) var suggestions: [Shoe] = []
    var suggestionCount: Int { suggestions.count }

    var isFavorite: Bool { FavoritesService.shared.isFavorite(shoe) }

    /// No se suscribe a `onProductsUpdate` a propósito: el detalle se instancia de nuevo
    /// en cada push (y el carrusel de sugerencias lleva a otro detalle), así que
    /// suscribirse acumularía observers que nadie da de baja.
    func loadSuggestions(completion: @escaping (Error?) -> Void) {
        if !ProductsService.shared.products.isEmpty {
            applySuggestions()
            completion(nil)
            return
        }
        // Se puede llegar aquí desde Favoritos sin haber abierto el Feed nunca, así que
        // no se puede asumir que el catálogo ya esté cargado.
        ProductsService.shared.fetchProducts { [weak self] result in
            switch result {
            case .success:
                self?.applySuggestions()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func applySuggestions() {
        suggestions = ProductsService.shared.products.filter { $0.uid != shoe.uid }
    }

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

    func addToCartTapped(completion: @escaping (Error?) -> Void) {
        onAddToCart?(shoe, quantity, completion)
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
