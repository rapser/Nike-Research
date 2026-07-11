final class MyOrdersViewModel {
    var onOrdersChanged: (() -> Void)?

    init() {
        OrdersService.shared.onOrdersUpdated = { [weak self] in
            self?.onOrdersChanged?()
        }
    }

    var title: String { "MY ORDERS" }
    var orders: [Order] { OrdersService.shared.orders }
    var count: Int { orders.count }
    var isEmpty: Bool { orders.isEmpty }

    func order(at index: Int) -> Order { orders[index] }
}
