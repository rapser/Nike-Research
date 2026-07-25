final class MyOrdersViewModel {
    var onOrdersChanged: (() -> Void)?

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
        OrdersService.shared.fetchOrders(completion: completion)
    }

    func order(at index: Int) -> Order { orders[index] }
}
