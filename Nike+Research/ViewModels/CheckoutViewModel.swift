import Foundation

final class CheckoutViewModel {
    var selectedCard: PaymentMethod? { didSet { onSelectionChanged?() } }
    var onSelectPaymentTapped: (() -> Void)?
    var onPlaceOrder: ((Order) -> Void)?
    var onSelectionChanged: (() -> Void)?

    var title: String { "CHECKOUT" }
    var subtotalText: String { format(CartService.shared.subtotal) }
    var taxText: String { format(CartService.shared.tax) }
    var shippingText: String { "FREE" }
    var totalText: String { format(CartService.shared.total) }

    var isFormValid: Bool { selectedCard != nil }
    var selectedCardTitle: String { selectedCard?.maskedDisplay ?? "Select payment method" }
    var selectedCardSubtitle: String? { selectedCard?.subtitle }
    var hasCard: Bool { selectedCard != nil }

    func selectPaymentTapped() { onSelectPaymentTapped?() }

    func placeOrder() {
        guard let card = selectedCard else { return }
        let order = Order(
            id: UUID().uuidString,
            number: String(format: "ORD-%06d", Int.random(in: 100000...999999)),
            items: CartService.shared.items.map {
                OrderItem(shoeName: $0.shoe.name, shoePrice: $0.shoe.price, quantity: $0.quantity)
            },
            subtotal: CartService.shared.subtotal,
            tax: CartService.shared.tax,
            shipping: CartService.shared.shipping,
            total: CartService.shared.total,
            paymentMethod: card,
            placedAt: Date()
        )
        onPlaceOrder?(order)
    }

    private func format(_ value: Double) -> String { String(format: "$%.2f", value) }
}
