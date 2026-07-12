import Foundation

final class AddCardViewModel {
    var holderName: String = ""
    var cardNumber: String = ""
    var cvv: String = ""
    var onCardSaved: (() -> Void)?

    private(set) var expiryMonth: Int
    private(set) var expiryYear: Int

    init() {
        let now = Calendar.current.dateComponents([.month, .year], from: Date())
        expiryMonth = now.month ?? 1
        expiryYear = now.year ?? 2026
    }

    var title: String { String(localized: "ADD CARD") }

    /// "MM/YY" — matches the backend's expected format (last two digits of the year).
    var expiryDate: String {
        String(format: "%02d/%02d", expiryMonth, expiryYear % 100)
    }

    var isValid: Bool {
        !holderName.isEmpty && cardNumber.passesLuhnCheck && cvv.count >= 3
    }

    func updateExpiry(month: Int, year: Int) {
        expiryMonth = month
        expiryYear = year
    }

    func saveCard(completion: @escaping (Error?) -> Void) {
        PaymentMethodsService.shared.create(holderName: holderName, cardNumber: cardNumber, expiryDate: expiryDate) { [weak self] error in
            if error == nil {
                self?.onCardSaved?()
            }
            completion(error)
        }
    }
}
