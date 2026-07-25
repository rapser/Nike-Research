import Foundation

final class CheckoutViewModel {
    var selectedCard: PaymentMethod? { didSet { onSelectionChanged?() } }
    var onSelectPaymentTapped: (() -> Void)?
    var onPlaceOrder: ((Order) -> Void)?
    var onCheckoutFailed: ((Error) -> Void)?
    var onSelectionChanged: (() -> Void)?

    var title: String { String(localized: "CHECKOUT") }
    var subtotalText: String { format(CartService.shared.subtotal) }
    var taxText: String { format(CartService.shared.tax) }
    var shippingText: String { String(localized: "FREE") }
    var totalText: String { format(CartService.shared.total) }

    var isFormValid: Bool { selectedCard != nil }
    var selectedCardTitle: String { selectedCard?.maskedDisplay ?? String(localized: "Select payment method") }
    var selectedCardSubtitle: String? { selectedCard?.subtitle }
    var hasCard: Bool { selectedCard != nil }

    func selectPaymentTapped() { onSelectPaymentTapped?() }

    func placeOrder() {
        guard let card = selectedCard else { return }
        OrdersService.shared.checkout(paymentMethodId: card.id) { [weak self] result in
            switch result {
            case .success(let order):
                self?.onPlaceOrder?(order)
            case .failure(let error):
                self?.onCheckoutFailed?(error)
            }
        }
    }

    private func format(_ value: Double) -> String { CurrencyFormatter.string(from: value) }
}
