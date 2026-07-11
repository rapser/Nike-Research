final class SelectCardViewModel {
    var onCardSelected: ((PaymentMethod) -> Void)?
    var onAddNewCard: (() -> Void)?
    var onCardsChanged: (() -> Void)?

    private(set) var selectedIndex: Int?

    init() {
        PaymentMethodsService.shared.onCardsUpdated = { [weak self] in
            self?.onCardsChanged?()
        }
    }

    var title: String { "SELECT CARD" }
    var cards: [PaymentMethod] { PaymentMethodsService.shared.cards }
    var cardCount: Int { cards.count }

    func card(at index: Int) -> PaymentMethod { cards[index] }

    func selectCard(at index: Int) {
        selectedIndex = index
        onCardSelected?(cards[index])
    }

    func addNewCardTapped() {
        onAddNewCard?()
    }

    func removeCard(at index: Int) {
        if selectedIndex == index { selectedIndex = nil }
        else if let sel = selectedIndex, sel > index { selectedIndex = sel - 1 }
        PaymentMethodsService.shared.remove(at: index)
    }
}
