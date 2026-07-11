final class CartViewModel {
    var onCartChanged: (() -> Void)?
    var onCheckoutTapped: (() -> Void)?

    init() {
        CartService.shared.onCartUpdated = { [weak self] in
            self?.onCartChanged?()
        }
    }

    var title: String { "MY BAG" }
    var items: [CartItem] { CartService.shared.items }
    var itemCount: Int { CartService.shared.items.count }
    var isEmpty: Bool { CartService.shared.items.isEmpty }

    var itemCountText: String {
        let n = CartService.shared.totalItemCount
        return "\(n) \(n == 1 ? "ITEM" : "ITEMS")"
    }

    var subtotalText: String { format(CartService.shared.subtotal) }
    var shippingText: String { "FREE" }
    var taxText: String { format(CartService.shared.tax) }
    var totalText: String { format(CartService.shared.total) }

    func removeItem(at index: Int) {
        CartService.shared.remove(at: index)
    }

    func checkoutTapped() {
        onCheckoutTapped?()
    }

    private func format(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
