final class MyOrdersViewModel {
    var onOrdersChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        OrdersService.shared.onOrdersUpdated = { [weak self] in
            self?.onOrdersChanged?()
        }
    }

    var title: String { String(localized: "MY ORDERS") }
    var orders: [Order] { OrdersService.shared.orders }
    var count: Int { orders.count }
    var isEmpty: Bool { orders.isEmpty }

    func loadOrders(completion: @escaping (Error?) -> Void) {
        // Sin sesión no se llama a la API: esta pantalla vive detrás de una ruta
        // protegida y la petición solo devolvería un 401.
        guard AuthService.shared.isAuthenticated else {
            state = .signedOut
            completion(nil)
            return
        }
        state = .loading
        OrdersService.shared.fetchOrders { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.isEmpty ? .empty : .loaded)
            completion(error)
        }
    }

    func order(at index: Int) -> Order { orders[index] }
}
