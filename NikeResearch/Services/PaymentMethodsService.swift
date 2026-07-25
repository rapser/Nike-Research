import Foundation

final class PaymentMethodsService {
    static let shared = PaymentMethodsService()
    private init() {}

    private(set) var cards: [PaymentMethod] = []

    /// Multicast: both `SelectCardViewModel` (checkout) and `MyCardsViewModel`
    /// (profile) subscribe, and a single closure property would let the second
    /// one silently clobber the first's subscription.
    private var updateObservers: [() -> Void] = []
    func onCardsUpdate(_ observer: @escaping () -> Void) {
        updateObservers.append(observer)
    }
    private func notifyUpdated() {
        updateObservers.forEach { $0() }
    }

    func fetchAll(completion: @escaping (Error?) -> Void) {
        APIClient.shared.request(.paymentMethods, decode: [PaymentMethodDTO].self) { [weak self] result in
            switch result {
            case .success(let dtos):
                self?.cards = dtos.map(Self.toPaymentMethod)
                self?.notifyUpdated()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func create(holderName: String, cardNumber: String, expiryDate: String, completion: @escaping (Error?) -> Void) {
        let body = CreatePaymentMethodRequestDTO(holderName: holderName, cardNumber: cardNumber, expiryDate: expiryDate, isDefault: nil)
        APIClient.shared.request(.createPaymentMethod, body: body, decode: PaymentMethodDTO.self) { [weak self] result in
            switch result {
            case .success(let dto):
                self?.cards.append(Self.toPaymentMethod(dto))
                self?.notifyUpdated()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func remove(at index: Int, completion: ((Error?) -> Void)? = nil) {
        guard index < cards.count else { return }
        let id = cards[index].id
        APIClient.shared.request(.removePaymentMethod(id: id), decode: [PaymentMethodDTO].self) { [weak self] result in
            switch result {
            case .success(let dtos):
                self?.cards = dtos.map(Self.toPaymentMethod)
                self?.notifyUpdated()
                completion?(nil)
            case .failure(let error):
                completion?(error)
            }
        }
    }

    /// Local-only reset, no network call — used on logout.
    func clearAll() {
        cards = []
        notifyUpdated()
    }

    private static func toPaymentMethod(_ dto: PaymentMethodDTO) -> PaymentMethod {
        PaymentMethod(id: dto.id, holderName: dto.holderName, cardBrand: dto.cardBrand, cardLast4: dto.cardLast4, expiryDate: dto.expiryDate)
    }
}
