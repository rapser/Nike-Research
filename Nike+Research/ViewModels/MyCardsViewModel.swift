final class MyCardsViewModel {
    var onCardsChanged: (() -> Void)?

    init() {
        PaymentMethodsService.shared.onCardsUpdated = { [weak self] in
            self?.onCardsChanged?()
        }
    }

    var title: String { "MY CARDS" }
    var cards: [PaymentMethod] { PaymentMethodsService.shared.cards }
    var count: Int { cards.count }

    func card(at index: Int) -> PaymentMethod { cards[index] }
    func remove(at index: Int) { PaymentMethodsService.shared.remove(at: index) }
}
