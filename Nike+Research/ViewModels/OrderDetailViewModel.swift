final class OrderDetailViewModel {
    private let order: Order

    init(order: Order) { self.order = order }

    var title: String { order.number }
    var date: String { "Placed on \(order.formattedDate)" }
    var estimatedDelivery: String { "Estimated delivery: \(order.estimatedDelivery)" }
    var paymentDisplay: String { order.paymentMethod.maskedDisplay }
    var paymentSubtitle: String { order.paymentMethod.subtitle }
    var itemCount: Int { order.items.count }

    func item(at index: Int) -> OrderItem { order.items[index] }

    var subtotalText: String { String(format: "$%.2f", order.subtotal) }
    var taxText: String { String(format: "$%.2f", order.tax) }
    var shippingText: String { "FREE" }
    var totalText: String { order.formattedTotal }
}
