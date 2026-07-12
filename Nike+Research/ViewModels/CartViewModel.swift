final class CartViewModel {
    var onCartChanged: (() -> Void)?
    var onCheckoutTapped: (() -> Void)?

    init() {
        CartService.shared.onCartUpdate { [weak self] in
            self?.onCartChanged?()
        }
    }

    var title: String { String(localized: "MY BAG") }
    var items: [CartItem] { CartService.shared.items }
    var itemCount: Int { CartService.shared.items.count }
    var isEmpty: Bool { CartService.shared.items.isEmpty }

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
        CartService.shared.fetchCart(completion: completion)
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
        String(format: "$%.2f", value)
    }
}
