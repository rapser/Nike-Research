final class CartViewModel {
    var onCartChanged: (() -> Void)?
    var onCheckoutTapped: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        CartService.shared.onCartUpdate { [weak self] in
            self?.onCartChanged?()
        }
    }

    var title: String { String(localized: "MY BAG") }
    var items: [CartItem] { CartService.shared.items }
    var itemCount: Int { CartService.shared.items.count }
    var isEmpty: Bool { CartService.shared.items.isEmpty }

    /// Durante la carga no se muestra ni el contenido ni la celda de "carrito vacío":
    /// la caché arranca en `[]`, así que `isEmpty` por sí solo no distingue "vacío" de
    /// "todavía no ha respondido el servidor".
    var showsEmptyState: Bool { state == .empty }
    var showsContent: Bool { state != .loading && !isEmpty }

    var itemCountText: String {
        let n = CartService.shared.totalItemCount
        let word = n == 1 ? String(localized: "ITEM") : String(localized: "ITEMS")
        return "\(n) \(word)"
    }

    var subtotalText: String { format(CartService.shared.subtotal) }
    var shippingText: String { String(localized: "FREE") }
    var taxText: String { format(CartService.shared.tax) }
    var totalText: String { format(CartService.shared.total) }

    func loadCart(completion: @escaping (Error?) -> Void) {
        state = .loading
        CartService.shared.fetchCart { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.isEmpty ? .empty : .loaded)
            completion(error)
        }
    }

    func removeItem(at index: Int, completion: ((Error?) -> Void)? = nil) {
        CartService.shared.remove(at: index, completion: completion)
    }

    /// Decrementing past 1 removes the item instead of sending an invalid
    /// `quantity: 0` to the server.
    func decrementQuantity(at index: Int, completion: ((Error?) -> Void)? = nil) {
        let items = CartService.shared.items
        guard index < items.count else { return }
        if items[index].quantity <= 1 {
            CartService.shared.remove(at: index, completion: completion)
        } else {
            CartService.shared.updateQuantity(at: index, quantity: items[index].quantity - 1, completion: completion)
        }
    }

    func incrementQuantity(at index: Int, completion: ((Error?) -> Void)? = nil) {
        let items = CartService.shared.items
        guard index < items.count else { return }
        CartService.shared.updateQuantity(at: index, quantity: items[index].quantity + 1, completion: completion)
    }

    func clearCart(completion: ((Error?) -> Void)? = nil) {
        CartService.shared.clear(completion: completion)
    }

    func checkoutTapped() {
        onCheckoutTapped?()
    }

    private func format(_ value: Double) -> String {
        CurrencyFormatter.string(from: value)
    }
}
