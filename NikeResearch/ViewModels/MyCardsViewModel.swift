final class MyCardsViewModel {
    var onCardsChanged: (() -> Void)?

    init() {
        PaymentMethodsService.shared.onCardsUpdate { [weak self] in
            self?.onCardsChanged?()
        }
    }

    var title: String { String(localized: "MY CARDS") }
    var cards: [PaymentMethod] { PaymentMethodsService.shared.cards }
    var count: Int { cards.count }

    func loadCards(completion: @escaping (Error?) -> Void) {
        PaymentMethodsService.shared.fetchAll(completion: completion)
    }

    func card(at index: Int) -> PaymentMethod { cards[index] }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        PaymentMethodsService.shared.remove(at: index, completion: completion)
    }
}
