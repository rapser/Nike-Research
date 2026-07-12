import Foundation

/// Same cached-property + `onCartUpdated` shape `CartViewModel` already reads
/// synchronously — only now the cache is populated from real `GET/POST/DELETE /cart*`
/// responses instead of local mutations. `subtotal`/`tax`/`shipping`/`total` come
/// straight from the server (source of truth for money math), not recomputed locally.
final class CartService {
    static let shared = CartService()
    private init() {}

    private(set) var items: [CartItem] = []

    /// Multicast on purpose: both `CartViewModel` (refreshes the cart screen) and
    /// `AppCoordinator` (refreshes the tab bar badge) need to hear about every
    /// mutation, not just the one that happens to register last.
    private var updateObservers: [() -> Void] = []
    func onCartUpdate(_ observer: @escaping () -> Void) {
        updateObservers.append(observer)
    }
    private func notifyUpdated() {
        updateObservers.forEach { $0() }
    }

    private(set) var subtotal: Double = 0
    private(set) var tax: Double = 0
    private(set) var shipping: Double = 0
    private(set) var total: Double = 0

    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func fetchCart(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.cart, decode: CartDTO.self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    func add(shoe: Shoe, quantity: Int = 1, completion: ((Error?) -> Void)? = nil) {
        let body = AddCartItemRequestDTO(productId: shoe.uid, quantity: quantity)
        APIClient.shared.request(.addCartItem, body: body, decode: CartDTO.self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// Sets the item's quantity to an absolute value via `PATCH`. Callers are
    /// expected to remove the item instead of calling this with `quantity < 1`
    /// (the server rejects that with a validation error).
    func updateQuantity(at index: Int, quantity: Int, completion: ((Error?) -> Void)? = nil) {
        guard index < items.count else { return }
        let itemId = items[index].id
        let body = UpdateCartItemRequestDTO(quantity: quantity)
        APIClient.shared.request(.updateCartItem(id: itemId), body: body, decode: CartDTO.self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        guard index < items.count else { return }
        let itemId = items[index].id
        APIClient.shared.request(.removeCartItem(id: itemId), decode: CartDTO.self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// `DELETE /cart` — empties the cart server-side. For the post-checkout
    /// sync (where the server already cleared the cart as part of `POST /orders`)
    /// use `clearAll()` instead to avoid a redundant network round trip.
    func clear(completion: ((Error?) -> Void)? = nil) {
        APIClient.shared.request(.clearCart, decode: CartDTO.self) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    /// Local-only reset, no network call — used right after a successful
    /// checkout, since the server already emptied the cart as part of that request.
    func clearAll() {
        items = []
        subtotal = 0
        tax = 0
        shipping = 0
        total = 0
        notifyUpdated()
    }

    private func handle(_ result: Result<CartDTO, APIError>, completion: ((Error?) -> Void)?) {
        switch result {
        case .success(let dto):
            apply(dto)
            completion?(nil)
        case .failure(let error):
            completion?(error)
        }
    }

    private func apply(_ dto: CartDTO) {
        items = dto.items.map { itemDTO in
            CartItem(id: itemDTO.id, shoe: ProductsService.toShoe(itemDTO.product), quantity: itemDTO.quantity)
        }
        subtotal = dto.subtotal
        tax = dto.tax
        shipping = dto.shipping
        total = dto.total
        notifyUpdated()
    }
}
