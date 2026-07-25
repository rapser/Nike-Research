final class OrderDetailViewModel {
    private let order: Order

    init(order: Order) { self.order = order }

    var title: String { order.number }
    var date: String { "\(String(localized: "Placed on")) \(order.formattedDate)" }
    var estimatedDelivery: String { "\(String(localized: "Estimated delivery:")) \(order.estimatedDelivery)" }
    var paymentDisplay: String { order.paymentMethod.maskedDisplay }
    var paymentSubtitle: String { order.paymentMethod.subtitle }
    var itemCount: Int { order.items.count }

    func item(at index: Int) -> OrderItem { order.items[index] }

    var subtotalText: String { CurrencyFormatter.string(from: order.subtotal) }
    var taxText: String { CurrencyFormatter.string(from: order.tax) }
    var shippingText: String { String(localized: "FREE") }
    var totalText: String { order.formattedTotal }
}
