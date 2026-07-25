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
        state = .loading
        OrdersService.shared.fetchOrders { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.isEmpty ? .empty : .loaded)
            completion(error)
        }
    }

    func order(at index: Int) -> Order { orders[index] }
}
