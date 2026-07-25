final class SelectCardViewModel {
    var onCardSelected: ((PaymentMethod) -> Void)?
    var onAddNewCard: (() -> Void)?
    var onCardsChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    private(set) var selectedIndex: Int?

    init() {
        PaymentMethodsService.shared.onCardsUpdate { [weak self] in
            self?.onCardsChanged?()
        }
    }

    var title: String { String(localized: "SELECT CARD") }
    var cards: [PaymentMethod] { PaymentMethodsService.shared.cards }
    var cardCount: Int { cards.count }

    func loadCards(completion: @escaping (Error?) -> Void) {
        state = .loading
        PaymentMethodsService.shared.fetchAll { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.cardCount == 0 ? .empty : .loaded)
            completion(error)
        }
    }

    func card(at index: Int) -> PaymentMethod { cards[index] }

    func selectCard(at index: Int) {
        selectedIndex = index
        onCardSelected?(cards[index])
    }

    func addNewCardTapped() {
        onAddNewCard?()
    }

    func removeCard(at index: Int, completion: ((Error?) -> Void)? = nil) {
        if selectedIndex == index { selectedIndex = nil }
        else if let sel = selectedIndex, sel > index { selectedIndex = sel - 1 }
        PaymentMethodsService.shared.remove(at: index, completion: completion)
    }
}
