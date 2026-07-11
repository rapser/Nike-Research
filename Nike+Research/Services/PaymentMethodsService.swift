final class PaymentMethodsService {
    static let shared = PaymentMethodsService()
    private init() {
        cards = [
            PaymentMethod(id: "demo-visa", holderName: "Jordan Runner",
                          cardNumber: "4111111111111111", expiryDate: "12/27"),
            PaymentMethod(id: "demo-mc", holderName: "Jordan Runner",
                          cardNumber: "5500000000000004", expiryDate: "09/26")
        ]
    }

    private(set) var cards: [PaymentMethod] = []
    var onCardsUpdated: (() -> Void)?

    func add(_ card: PaymentMethod) {
        cards.append(card)
        onCardsUpdated?()
    }

    func remove(at index: Int) {
        guard index < cards.count else { return }
        cards.remove(at: index)
        onCardsUpdated?()
    }
}
