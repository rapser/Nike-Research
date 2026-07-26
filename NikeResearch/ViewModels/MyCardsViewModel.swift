final class MyCardsViewModel {
    var onCardsChanged: (() -> Void)?
    var onStateChanged: (() -> Void)?

    private(set) var state: LoadState = .loading {
        didSet { onStateChanged?() }
    }

    init() {
        PaymentMethodsService.shared.onCardsUpdate { [weak self] in
            self?.onCardsChanged?()
        }
    }

    var title: String { String(localized: "MY CARDS") }
    var cards: [PaymentMethod] { PaymentMethodsService.shared.cards }
    var count: Int { cards.count }

    func loadCards(completion: @escaping (Error?) -> Void) {
        // Sin sesión no se llama a la API: esta pantalla vive detrás de una ruta
        // protegida y la petición solo devolvería un 401.
        guard AuthService.shared.isAuthenticated else {
            state = .signedOut
            completion(nil)
            return
        }
        state = .loading
        PaymentMethodsService.shared.fetchAll { [weak self] error in
            guard let self else { return }
            self.state = error != nil ? .failed : (self.count == 0 ? .empty : .loaded)
            completion(error)
        }
    }

    func card(at index: Int) -> PaymentMethod { cards[index] }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        PaymentMethodsService.shared.remove(at: index, completion: completion)
    }
}
