final class OrdersService {
    static let shared = OrdersService()
    private init() {}

    private(set) var orders: [Order] = []
    var onOrdersUpdated: (() -> Void)?

    func save(_ order: Order) {
        orders.insert(order, at: 0)
        onOrdersUpdated?()
    }
}
