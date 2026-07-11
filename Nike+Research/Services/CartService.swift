final class CartService {
    static let shared = CartService()
    private init() {}

    private(set) var items: [CartItem] = []
    var onCartUpdated: (() -> Void)?

    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var tax: Double { subtotal * 0.10 }
    var shipping: Double { 0 }
    var total: Double { subtotal + tax + shipping }

    func add(shoe: Shoe) {
        if let idx = items.firstIndex(where: { $0.shoe.uid == shoe.uid }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(shoe: shoe, quantity: 1))
        }
        onCartUpdated?()
    }

    func remove(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        onCartUpdated?()
    }

    func clearAll() {
        items = []
        onCartUpdated?()
    }
}
